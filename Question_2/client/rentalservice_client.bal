import ballerina/io;
import quinton/question_2.generated;

RentalServiceClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    AddPropertyRequest add_propertyRequest = {property_name: "ballerina", location: "ballerina", property_type: "ballerina", price_per_night: 1, host_id: "ballerina", status: "ballerina"};
    AddPropertyResponse add_propertyResponse = check ep->add_property(add_propertyRequest);
    io:println(add_propertyResponse);

    UpdatePropertyRequest update_propertyRequest = {property_id: "ballerina", property_name: "ballerina", location: "ballerina", property_type: "ballerina", price_per_night: 1, status: "ballerina"};
    UpdatePropertyResponse update_propertyResponse = check ep->update_property(update_propertyRequest);
    io:println(update_propertyResponse);

    RemovePropertyRequest remove_propertyRequest = {property_id: "ballerina", host_id: "ballerina"};
    RemovePropertyResponse remove_propertyResponse = check ep->remove_property(remove_propertyRequest);
    io:println(remove_propertyResponse);

    SearchPropertyRequest search_propertyRequest = {property_id: "ballerina"};
    SearchPropertyResponse search_propertyResponse = check ep->search_property(search_propertyRequest);
    io:println(search_propertyResponse);

    BookPropertyRequest book_propertyRequest = {property_id: "ballerina", guest_id: "ballerina", check_in: "ballerina", check_out: "ballerina"};
    BookPropertyResponse book_propertyResponse = check ep->book_property(book_propertyRequest);
    io:println(book_propertyResponse);

    ConfirmBookingRequest confirm_bookingRequest = {guest_id: "ballerina"};
    ConfirmBookingResponse confirm_bookingResponse = check ep->confirm_booking(confirm_bookingRequest);
    io:println(confirm_bookingResponse);

    CancelBookingRequest cancel_bookingRequest = {booking_id: "ballerina", guest_id: "ballerina"};
    CancelBookingResponse cancel_bookingResponse = check ep->cancel_booking(cancel_bookingRequest);
    io:println(cancel_bookingResponse);

    ListPropertiesRequest list_available_propertiesRequest = {location: "ballerina", min_price: 1, max_price: 1};
    stream<Property, error?> list_available_propertiesResponse = check ep->list_available_properties(list_available_propertiesRequest);
    check list_available_propertiesResponse.forEach(function(Property value) {
        io:println(value);
    });

    ListHostPropertiesRequest list_host_propertiesRequest = {host_id: "ballerina"};
    stream<Property, error?> list_host_propertiesResponse = check ep->list_host_properties(list_host_propertiesRequest);
    check list_host_propertiesResponse.forEach(function(Property value) {
        io:println(value);
    });

    ViewMyBookingsRequest view_my_bookingsRequest = {guest_id: "ballerina"};
    stream<Booking, error?> view_my_bookingsResponse = check ep->view_my_bookings(view_my_bookingsRequest);
    check view_my_bookingsResponse.forEach(function(Booking value) {
        io:println(value);
    });

    CreateUserRequest create_usersRequest = {name: "ballerina", email: "ballerina", role: "ballerina", region: "ballerina"};
    Create_usersStreamingClient create_usersStreamingClient = check ep->create_users();
    check create_usersStreamingClient->sendCreateUserRequest(create_usersRequest);
    check create_usersStreamingClient->complete();
    CreateUsersResponse? create_usersResponse = check create_usersStreamingClient->receiveCreateUsersResponse();
    io:println(create_usersResponse);
}
