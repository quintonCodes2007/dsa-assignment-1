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

    }
}