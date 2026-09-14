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
    
}