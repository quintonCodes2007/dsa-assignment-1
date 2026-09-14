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

    
}