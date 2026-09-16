import ballerina/io;

public function main() returns error? {

    RentalServiceClient ep = check new ("http://localhost:9090");

    while true {
        io:println("\n=================================");
        io:println("   RENTAL ACCOMMODATION SYSTEM");
        io:println("=================================");
        io:println("1. Create Users");
        io:println("2. Add Property");
        io:println("3. Search Property");
        io:println("4. Update Property");
        io:println("5. List Available Properties");
        io:println("6. List Host Properties");
        io:println("7. Book Property");
        io:println("8. Confirm Booking");
        io:println("9. View My Bookings");
        io:println("10. Cancel Booking");
        io:println("11. Remove Property");
        io:println("0. Exit");
        io:println("=================================");

        string choice = io:readln("Choose an option: ");

        if choice == "0" {
            io:println("Goodbye!");
            break;
        }

        if choice == "1" {
            check createUsers(ep);
        } else if choice == "2" {
            check addProperty(ep);
        } else if choice == "3" {
            check searchProperty(ep);
        } else if choice == "4" {
            check updateProperty(ep);
        } else if choice == "5" {
            check listAvailableProperties(ep);
        } else if choice == "6" {
            check listHostProperties(ep);
        } else if choice == "7" {
            check bookProperty(ep);
        } else if choice == "8" {
            check confirmBooking(ep);
        } else if choice == "9" {
            check viewMyBookings(ep);
        } else if choice == "10" {
            check cancelBooking(ep);
        } else if choice == "11" {
            check removeProperty(ep);
        } else {
            io:println("Invalid option.");
        }
    }
}


// =========================================
// 1. CREATE USERS
// =========================================

function createUsers(RentalServiceClient ep) returns error? {

    io:println("\n--- CREATE USER ---");

    string name = io:readln("Name: ");
    string email = io:readln("Email: ");
    string role = io:readln("Role (HOST/GUEST): ");
    string region = io:readln("Region: ");

    CreateUserRequest userRequest = {
        name: name,
        email: email,
        role: role,
        region: region
    };

    Create_usersStreamingClient createUsersClient =
        check ep->create_users();

    check createUsersClient->sendCreateUserRequest(userRequest);

    check createUsersClient->complete();

    CreateUsersResponse? response =
        check createUsersClient->receiveCreateUsersResponse();

    io:println("\nCreate user response: ", response);
}


// =========================================
// 2. ADD PROPERTY
// =========================================

function addProperty(RentalServiceClient ep) returns error? {

    io:println("\n--- ADD PROPERTY ---");

    string propertyName = io:readln("Property name: ");
    string location = io:readln("Location: ");
    string propertyType = io:readln("Property type: ");
    string priceInput = io:readln("Price per night: ");
    string hostId = io:readln("Host ID: ");
    string status = io:readln("Status (AVAILABLE/UNAVAILABLE): ");

    float price = check float:fromString(priceInput);

    AddPropertyRequest request = {
        property_name: propertyName,
        location: location,
        property_type: propertyType,
        price_per_night: price,
        host_id: hostId,
        status: status
    };

    AddPropertyResponse response =
        check ep->add_property(request);

    io:println("\nProperty added successfully!");
    io:println("Property ID: ", response.property_id);
}


// =========================================
// 3. SEARCH PROPERTY
// =========================================

function searchProperty(RentalServiceClient ep) returns error? {

    io:println("\n--- SEARCH PROPERTY ---");

    string propertyId = io:readln("Property ID: ");

    SearchPropertyRequest request = {
        property_id: propertyId
    };

    SearchPropertyResponse response =
        check ep->search_property(request);

    io:println("\nSearch result:");
    io:println(response);
}


// =========================================
// 4. UPDATE PROPERTY
// =========================================

function updateProperty(RentalServiceClient ep) returns error? {

    io:println("\n--- UPDATE PROPERTY ---");

    string propertyId = io:readln("Property ID: ");
    string propertyName = io:readln("New property name: ");
    string location = io:readln("New location: ");
    string propertyType = io:readln("New property type: ");
    string priceInput = io:readln("New price per night: ");
    string status = io:readln("New status (AVAILABLE/UNAVAILABLE): ");

    float price = check float:fromString(priceInput);

    UpdatePropertyRequest request = {
        property_id: propertyId,
        property_name: propertyName,
        location: location,
        property_type: propertyType,
        price_per_night: price,
        status: status
    };

    UpdatePropertyResponse response =
        check ep->update_property(request);

    io:println("\nUpdate result:");
    io:println(response);
}


// =========================================
// 5. LIST AVAILABLE PROPERTIES
// =========================================

function listAvailableProperties(RentalServiceClient ep) returns error? {

    io:println("\n--- LIST AVAILABLE PROPERTIES ---");

    string location = io:readln("Location (leave empty for any): ");
    string minPriceInput = io:readln("Minimum price (0 for any): ");
    string maxPriceInput = io:readln("Maximum price (0 for any): ");

    float minPrice = check float:fromString(minPriceInput);
    float maxPrice = check float:fromString(maxPriceInput);

    ListPropertiesRequest request = {
        location: location,
        min_price: minPrice,
        max_price: maxPrice
    };

    stream<Property, error?> response =
        check ep->list_available_properties(request);

    io:println("\nAvailable properties:");

    check response.forEach(function(Property property) {
        io:println(property);
    });
}


// =========================================
// 6. LIST HOST PROPERTIES
// =========================================

function listHostProperties(RentalServiceClient ep) returns error? {

    io:println("\n--- LIST HOST PROPERTIES ---");

    string hostId = io:readln("Host ID: ");

    ListHostPropertiesRequest request = {
        host_id: hostId
    };

    stream<Property, error?> response =
        check ep->list_host_properties(request);

    io:println("\nProperties belonging to ", hostId, ":");

    check response.forEach(function(Property property) {
        io:println(property);
    });
}


// =========================================
// 7. BOOK PROPERTY
// =========================================

function bookProperty(RentalServiceClient ep) returns error? {

    io:println("\n--- BOOK PROPERTY ---");

    string propertyId = io:readln("Property ID: ");
    string guestId = io:readln("Guest ID: ");
    string checkIn = io:readln("Check-in date (YYYY-MM-DD): ");
    string checkOut = io:readln("Check-out date (YYYY-MM-DD): ");

    BookPropertyRequest request = {
        property_id: propertyId,
        guest_id: guestId,
        check_in: checkIn,
        check_out: checkOut
    };

    BookPropertyResponse response =
        check ep->book_property(request);

    io:println("\nBooking result:");
    io:println(response);
}


// =========================================
// 8. CONFIRM BOOKING
// =========================================

function confirmBooking(RentalServiceClient ep) returns error? {

    io:println("\n--- CONFIRM BOOKING ---");

    string guestId = io:readln("Guest ID: ");

    ConfirmBookingRequest request = {
        guest_id: guestId
    };

    ConfirmBookingResponse response =
        check ep->confirm_booking(request);

    io:println("\nConfirmation result:");
    io:println(response);

    if response.booking is Booking {
        io:println("Booking ID: ", response.booking.booking_id);
    }
}


// =========================================
// 9. VIEW MY BOOKINGS
// =========================================

function viewMyBookings(RentalServiceClient ep) returns error? {

    io:println("\n--- VIEW MY BOOKINGS ---");

    string guestId = io:readln("Guest ID: ");

    ViewMyBookingsRequest request = {
        guest_id: guestId
    };

    stream<Booking, error?> response =
        check ep->view_my_bookings(request);

    io:println("\nBookings for ", guestId, ":");

    check response.forEach(function(Booking booking) {
        io:println(booking);
    });
}


// =========================================
// 10. CANCEL BOOKING
// =========================================

function cancelBooking(RentalServiceClient ep) returns error? {

    io:println("\n--- CANCEL BOOKING ---");

    string bookingId = io:readln("Booking ID: ");
    string guestId = io:readln("Guest ID: ");

    CancelBookingRequest request = {
        booking_id: bookingId,
        guest_id: guestId
    };

    CancelBookingResponse response =
        check ep->cancel_booking(request);

    io:println("\nCancellation result:");
    io:println(response);
}


// =========================================
// 11. REMOVE PROPERTY
// =========================================

function removeProperty(RentalServiceClient ep) returns error? {

    io:println("\n--- REMOVE PROPERTY ---");

    string propertyId = io:readln("Property ID: ");
    string hostId = io:readln("Host ID: ");

    RemovePropertyRequest request = {
        property_id: propertyId,
        host_id: hostId
    };

    RemovePropertyResponse response =
        check ep->remove_property(request);

    io:println("\nRemove result:");
    io:println(response);
}

