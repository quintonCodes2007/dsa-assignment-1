import ballerina/grpc;
import quinton/question_2.generated;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: RENTAL_DESC}
service "RentalService" on ep {

    remote function add_property(AddPropertyRequest value) returns AddPropertyResponse|error {
    }

    remote function update_property(UpdatePropertyRequest value) returns UpdatePropertyResponse|error {
    }

    remote function remove_property(RemovePropertyRequest value) returns RemovePropertyResponse|error {
    }

    remote function search_property(SearchPropertyRequest value) returns SearchPropertyResponse|error {
    }

    remote function book_property(BookPropertyRequest value) returns BookPropertyResponse|error {
    }

    remote function confirm_booking(ConfirmBookingRequest value) returns ConfirmBookingResponse|error {
    }

    remote function cancel_booking(CancelBookingRequest value) returns CancelBookingResponse|error {
    }

    remote function create_users(stream<CreateUserRequest, grpc:Error?> clientStream) returns CreateUsersResponse|error {
    }

    remote function list_available_properties(ListPropertiesRequest value) returns stream<Property, error?>|error {
    }

    remote function list_host_properties(ListHostPropertiesRequest value) returns stream<Property, error?>|error {
    }

    remote function view_my_bookings(ViewMyBookingsRequest value) returns stream<Booking, error?>|error {
    }
}
