import ballerina/grpc;
import ballerina/time;

listener grpc:Listener ep = new (9090);

function calculateNights(string checkIn, string checkOut) returns int|error {
    time:Utc inUtc = check time:utcFromString(checkIn + "T00:00:00.00Z");
    time:Utc outUtc = check time:utcFromString(checkOut + "T00:00:00.00Z");
    int differenceSeconds = outUtc[0] - inUtc[0];
    return differenceSeconds / (24 * 60 * 60);
}

@grpc:Descriptor {value: RENTAL_DESC}
service "RentalService" on ep {

    private map<Property> properties = {};
    private map<BookPropertyRequest> bookingCart = {};
    private map<Booking> bookings = {};
    private map<CreateUserRequest> users = {};
function stripSpaces(string input) returns string {
        string result = "";
        foreach string:Char c in input {
            if c != " " && c != "\t" && c != "\n" {
                result += c;
            }
        }
        return result;
    }
        function generatePropertyId(string propertyName, string location) returns string {
        string nameCode = self.stripSpaces(propertyName.toUpperAscii());
        string locationCode = self.stripSpaces(location.toUpperAscii());

        if nameCode.length() > 3 {
            nameCode = nameCode.substring(0, 3);
        }
        if locationCode.length() > 3 {
            locationCode = locationCode.substring(0, 3);
        }

        int count = 1;
        string propertyId = "";
        while true {
            string number = count.toString();
            while number.length() < 3 {
                number = "0" + number;
            }
            propertyId = nameCode + "-" + locationCode + "-" + number;
            if !self.properties.hasKey(propertyId) {
                return propertyId;
            }
            count += 1;
        }
    }
        function generateBookingId() returns string {
        int count = self.bookings.length() + 1;
        while true {
            string bookingId = "BOOK-" + count.toString();
            if !self.bookings.hasKey(bookingId) {
                return bookingId;
            }
            count += 1;
        
        }
    }
    remote function add_property(AddPropertyRequest value) returns AddPropertyResponse|error {
        string propertyId = self.generatePropertyId(value.property_name, value.location);
        Property newProperty = {
            property_id: propertyId,
            host_id: value.host_id,
            property_name: value.property_name,
            location: value.location,
            property_type: value.property_type,
            price_per_night: value.price_per_night,
            status: value.status
        };
        self.properties[propertyId] = newProperty;
        return {property_id: propertyId};
    }

    remote function update_property(UpdatePropertyRequest value) returns UpdatePropertyResponse|error {
        Property? existingProperty = self.properties[value.property_id];
        if existingProperty is Property {
            Property updatedProperty = {
                property_id: existingProperty.property_id,
                host_id: existingProperty.host_id,
                property_name: value.property_name,
                location: value.location,
                property_type: value.property_type,
                price_per_night: value.price_per_night,
                status: value.status
            };
            self.properties[value.property_id] = updatedProperty;
            return {message: "Property updated successfully", success: true};
        }
        return {message: "Property not found", success: false};
    }

    remote function remove_property(RemovePropertyRequest value) returns RemovePropertyResponse|error {
        Property? property = self.properties[value.property_id];
        if property is Property {
            if property.host_id != value.host_id {
                return {
                    message: "You are not authorized to remove this property",
                    properties: []
                };
            }

            _ = self.properties.remove(value.property_id);

            Property[] remainingProperties = [];
            foreach Property remainingProperty in self.properties {
                if remainingProperty.host_id == value.host_id {
                    remainingProperties.push(remainingProperty);
                }
            }
            return {
                message: "Property removed successfully",
                properties: remainingProperties
            };
        }
        return {message: "Property not found", properties: []};
    }
remote function search_property(SearchPropertyRequest value) returns SearchPropertyResponse|error {
        Property? property = self.properties[value.property_id];
        if property is Property {
            if property.status == "AVAILABLE" {
                return {status: "Available", property: property};
            }
            return {status: "Not Available"};
        }
        return {status: "Property Not Found"};
    }

    remote function book_property(BookPropertyRequest value) returns BookPropertyResponse|error {
        Property? property = self.properties[value.property_id];
        if property is Property {
            if property.status != "AVAILABLE" {
                return {message: "Property is not available", success: false};
            }
            if value.check_in >= value.check_out {
                return {
                    message: "Check-out date must be after check-in date",
                    success: false
                };
            }
            self.bookingCart[value.guest_id] = value;
            return {message: "Property added to booking cart", success: true};
        }
        return {message: "Property not found", success: false};
    }

    remote function confirm_booking(ConfirmBookingRequest value) returns ConfirmBookingResponse|error {
        BookPropertyRequest? request = self.bookingCart[value.guest_id];
        if request is BookPropertyRequest {
            Property? property = self.properties[request.property_id];
            if property is Property {
                if property.status != "AVAILABLE" {
                    return {message: "Property is no longer available"};
                }

                int numberOfNights = check calculateNights(request.check_in, request.check_out);
                if numberOfNights <= 0 {
                    return {message: "Invalid booking dates"};
                }

                foreach Booking booking in self.bookings {
                    if booking.property_id == request.property_id &&
                        booking.status == "CONFIRMED" &&
                        request.check_in < booking.check_out &&
                        request.check_out > booking.check_in {
                        return {message: "Property is already booked for these dates"};
                    }
                }

                string bookingId = self.generateBookingId();
                float totalCost = property.price_per_night * <float>numberOfNights;

                Booking newBooking = {
                    booking_id: bookingId,
                    property_id: request.property_id,
                    guest_id: request.guest_id,
                    check_in: request.check_in,
                    check_out: request.check_out,
                    number_of_nights: numberOfNights,
                    total_cost: totalCost,
                    status: "CONFIRMED"
                };
                self.bookings[bookingId] = newBooking;
                _ = self.bookingCart.remove(value.guest_id);
                return {
                    message: "Booking confirmed successfully",
                    booking: newBooking
                };
            }
            return {message: "Property not found"};
        }
        return {message: "No booking found in cart"};
    }

    remote function cancel_booking(CancelBookingRequest value) returns CancelBookingResponse|error {
        Booking? booking = self.bookings[value.booking_id];
        if booking is Booking {
            if booking.guest_id != value.guest_id {
                return {message: "You are not authorized to cancel this booking"};
            }
            if booking.status != "CONFIRMED" {
                return {message: "Booking cannot be cancelled"};
            }

            Booking cancelledBooking = {
                booking_id: booking.booking_id,
                property_id: booking.property_id,
                guest_id: booking.guest_id,
                check_in: booking.check_in,
                check_out: booking.check_out,
                number_of_nights: booking.number_of_nights,
                total_cost: booking.total_cost,
                status: "CANCELLED"
            };
            self.bookings[value.booking_id] = cancelledBooking;
            return {
                message: "Booking cancelled successfully",
                booking: cancelledBooking
            };
        }
        return {message: "Booking not found"};
    }

    remote function create_users(stream<CreateUserRequest, grpc:Error?> clientStream)
            returns CreateUsersResponse|error {
        int usersCreated = 0;
        record {|CreateUserRequest value;|}|grpc:Error? result = clientStream.next();
        while result is record {|CreateUserRequest value;|} {
            string userId = "USER-" + (self.users.length() + 1).toString();
            self.users[userId] = result.value;
            usersCreated += 1;
            result = clientStream.next();
        }
        return {message: "Users created successfully", users_created: usersCreated};
    }

    remote function list_available_properties(ListPropertiesRequest value)
            returns stream<Property, error?>|error {
        Property[] result = [];
        foreach Property property in self.properties {
            if property.status != "AVAILABLE" {
                continue;
            }
            if value.location != "" && property.location != value.location {
                continue;
            }
            if value.min_price > 0.0 && property.price_per_night < value.min_price {
                continue;
            }
            if value.max_price > 0.0 && property.price_per_night > value.max_price {
                continue;
            }
            result.push(property);
        }
        return result.toStream();
    }

    remote function list_host_properties(ListHostPropertiesRequest value)
            returns stream<Property, error?>|error {
        Property[] result = [];
        foreach Property property in self.properties {
            if property.host_id == value.host_id {
                result.push(property);
            }
        }
        return result.toStream();
    }

    remote function view_my_bookings(ViewMyBookingsRequest value)
            returns stream<Booking, error?>|error {
        Booking[] result = [];
        foreach Booking booking in self.bookings {
            if booking.guest_id == value.guest_id {
                result.push(booking);
            }
        }
        return result.toStream();
    }
    }
