import ballerina/grpc;
import ballerina/protobuf;

public const string RENTAL_DESC = "0A0C72656E74616C2E70726F746F22EA010A0850726F7065727479121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F7374496412230A0D70726F70657274795F6E616D65180320012809520C70726F70657274794E616D65121A0A086C6F636174696F6E18042001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180520012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180620012801520D70726963655065724E6967687412160A06737461747573180720012809520673746174757322D3010A1241646450726F70657274795265717565737412230A0D70726F70657274795F6E616D65180120012809520C70726F70657274794E616D65121A0A086C6F636174696F6E18022001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180320012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180420012801520D70726963655065724E6967687412170A07686F73745F69641805200128095206686F7374496412160A06737461747573180620012809520673746174757322360A1341646450726F7065727479526573706F6E7365121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496422690A11437265617465557365725265717565737412120A046E616D6518012001280952046E616D6512140A05656D61696C1802200128095205656D61696C12120A04726F6C651803200128095204726F6C6512160A06726567696F6E1804200128095206726567696F6E22540A134372656174655573657273526573706F6E736512180A076D65737361676518012001280952076D65737361676512230A0D75736572735F63726561746564180220012805520C75736572734372656174656422DE010A1555706461746550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412230A0D70726F70657274795F6E616D65180220012809520C70726F70657274794E616D65121A0A086C6F636174696F6E18032001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180420012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180520012801520D70726963655065724E6967687412160A067374617475731806200128095206737461747573224C0A1655706461746550726F7065727479526573706F6E736512180A076D65737361676518012001280952076D65737361676512180A077375636365737318022001280852077375636365737322510A1552656D6F766550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F73744964225D0A1652656D6F766550726F7065727479526573706F6E736512180A076D65737361676518012001280952076D65737361676512290A0A70726F7065727469657318022003280B32092E50726F7065727479520A70726F70657274696573226D0A154C69737450726F7065727469657352657175657374121A0A086C6F636174696F6E18012001280952086C6F636174696F6E121B0A096D696E5F707269636518022001280152086D696E5072696365121B0A096D61785F707269636518032001280152086D6178507269636522380A1553656172636850726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496422570A1653656172636850726F7065727479526573706F6E736512160A06737461747573180120012809520673746174757312250A0870726F706572747918022001280B32092E50726F7065727479520870726F706572747922FD010A07426F6F6B696E67121D0A0A626F6F6B696E675F69641801200128095209626F6F6B696E674964121F0A0B70726F70657274795F6964180220012809520A70726F7065727479496412190A0867756573745F696418032001280952076775657374496412190A08636865636B5F696E1804200128095207636865636B496E121B0A09636865636B5F6F75741805200128095208636865636B4F757412280A106E756D6265725F6F665F6E6967687473180620012805520E6E756D6265724F664E6967687473121D0A0A746F74616C5F636F73741807200128015209746F74616C436F737412160A0673746174757318082001280952067374617475732289010A13426F6F6B50726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412190A0867756573745F696418022001280952076775657374496412190A08636865636B5F696E1803200128095207636865636B496E121B0A09636865636B5F6F75741804200128095208636865636B4F7574224A0A14426F6F6B50726F7065727479526573706F6E736512180A076D65737361676518012001280952076D65737361676512180A077375636365737318022001280852077375636365737322320A15436F6E6669726D426F6F6B696E675265717565737412190A0867756573745F696418012001280952076775657374496422560A16436F6E6669726D426F6F6B696E67526573706F6E736512180A076D65737361676518012001280952076D65737361676512220A07626F6F6B696E6718022001280B32082E426F6F6B696E675207626F6F6B696E6722340A194C697374486F737450726F706572746965735265717565737412170A07686F73745F69641801200128095206686F7374496422320A15566965774D79426F6F6B696E67735265717565737412190A0867756573745F696418012001280952076775657374496422500A1443616E63656C426F6F6B696E6752657175657374121D0A0A626F6F6B696E675F69641801200128095209626F6F6B696E67496412190A0867756573745F696418022001280952076775657374496422550A1543616E63656C426F6F6B696E67526573706F6E736512180A076D65737361676518012001280952076D65737361676512220A07626F6F6B696E6718022001280B32082E426F6F6B696E675207626F6F6B696E6732D0050A0D52656E74616C5365727669636512390A0C6164645F70726F706572747912132E41646450726F7065727479526571756573741A142E41646450726F7065727479526573706F6E7365123A0A0C6372656174655F757365727312122E43726561746555736572526571756573741A142E4372656174655573657273526573706F6E7365280112420A0F7570646174655F70726F706572747912162E55706461746550726F7065727479526571756573741A172E55706461746550726F7065727479526573706F6E736512420A0F72656D6F76655F70726F706572747912162E52656D6F766550726F7065727479526571756573741A172E52656D6F766550726F7065727479526573706F6E736512400A196C6973745F617661696C61626C655F70726F7065727469657312162E4C69737450726F70657274696573526571756573741A092E50726F7065727479300112420A0F7365617263685F70726F706572747912162E53656172636850726F7065727479526571756573741A172E53656172636850726F7065727479526573706F6E7365123C0A0D626F6F6B5F70726F706572747912142E426F6F6B50726F7065727479526571756573741A152E426F6F6B50726F7065727479526573706F6E736512420A0F636F6E6669726D5F626F6F6B696E6712162E436F6E6669726D426F6F6B696E67526571756573741A172E436F6E6669726D426F6F6B696E67526573706F6E7365123F0A0E63616E63656C5F626F6F6B696E6712152E43616E63656C426F6F6B696E67526571756573741A162E43616E63656C426F6F6B696E67526573706F6E7365123F0A146C6973745F686F73745F70726F70657274696573121A2E4C697374486F737450726F70657274696573526571756573741A092E50726F7065727479300112360A10766965775F6D795F626F6F6B696E677312162E566965774D79426F6F6B696E6773526571756573741A082E426F6F6B696E673001620670726F746F33";

public isolated client class RentalServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, RENTAL_DESC);
    }

    isolated remote function add_property(AddPropertyRequest|ContextAddPropertyRequest req) returns AddPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyRequest message;
        if req is ContextAddPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/add_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddPropertyResponse>result;
    }

    isolated remote function add_propertyContext(AddPropertyRequest|ContextAddPropertyRequest req) returns ContextAddPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyRequest message;
        if req is ContextAddPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/add_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function update_property(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns UpdatePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/update_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UpdatePropertyResponse>result;
    }

    isolated remote function update_propertyContext(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns ContextUpdatePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/update_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UpdatePropertyResponse>result, headers: respHeaders};
    }

    isolated remote function remove_property(RemovePropertyRequest|ContextRemovePropertyRequest req) returns RemovePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/remove_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RemovePropertyResponse>result;
    }

    isolated remote function remove_propertyContext(RemovePropertyRequest|ContextRemovePropertyRequest req) returns ContextRemovePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/remove_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RemovePropertyResponse>result, headers: respHeaders};
    }

    isolated remote function search_property(SearchPropertyRequest|ContextSearchPropertyRequest req) returns SearchPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/search_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchPropertyResponse>result;
    }

    isolated remote function search_propertyContext(SearchPropertyRequest|ContextSearchPropertyRequest req) returns ContextSearchPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/search_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function book_property(BookPropertyRequest|ContextBookPropertyRequest req) returns BookPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/book_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <BookPropertyResponse>result;
    }

    isolated remote function book_propertyContext(BookPropertyRequest|ContextBookPropertyRequest req) returns ContextBookPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/book_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <BookPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function confirm_booking(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ConfirmBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/confirm_booking", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ConfirmBookingResponse>result;
    }

    isolated remote function confirm_bookingContext(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ContextConfirmBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/confirm_booking", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ConfirmBookingResponse>result, headers: respHeaders};
    }

    isolated remote function cancel_booking(CancelBookingRequest|ContextCancelBookingRequest req) returns CancelBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        CancelBookingRequest message;
        if req is ContextCancelBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/cancel_booking", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <CancelBookingResponse>result;
    }

    isolated remote function cancel_bookingContext(CancelBookingRequest|ContextCancelBookingRequest req) returns ContextCancelBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        CancelBookingRequest message;
        if req is ContextCancelBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("RentalService/cancel_booking", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <CancelBookingResponse>result, headers: respHeaders};
    }

    isolated remote function create_users() returns Create_usersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("RentalService/create_users");
        return new Create_usersStreamingClient(sClient);
    }

    isolated remote function list_available_properties(ListPropertiesRequest|ContextListPropertiesRequest req) returns stream<Property, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListPropertiesRequest message;
        if req is ContextListPropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("RentalService/list_available_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return new stream<Property, grpc:Error?>(outputStream);
    }

    isolated remote function list_available_propertiesContext(ListPropertiesRequest|ContextListPropertiesRequest req) returns ContextPropertyStream|grpc:Error {
        map<string|string[]> headers = {};
        ListPropertiesRequest message;
        if req is ContextListPropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("RentalService/list_available_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return {content: new stream<Property, grpc:Error?>(outputStream), headers: respHeaders};
    }

    isolated remote function list_host_properties(ListHostPropertiesRequest|ContextListHostPropertiesRequest req) returns stream<Property, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListHostPropertiesRequest message;
        if req is ContextListHostPropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("RentalService/list_host_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return new stream<Property, grpc:Error?>(outputStream);
    }

    isolated remote function list_host_propertiesContext(ListHostPropertiesRequest|ContextListHostPropertiesRequest req) returns ContextPropertyStream|grpc:Error {
        map<string|string[]> headers = {};
        ListHostPropertiesRequest message;
        if req is ContextListHostPropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("RentalService/list_host_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return {content: new stream<Property, grpc:Error?>(outputStream), headers: respHeaders};
    }

    isolated remote function view_my_bookings(ViewMyBookingsRequest|ContextViewMyBookingsRequest req) returns stream<Booking, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ViewMyBookingsRequest message;
        if req is ContextViewMyBookingsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("RentalService/view_my_bookings", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        BookingStream outputStream = new BookingStream(result);
        return new stream<Booking, grpc:Error?>(outputStream);
    }

    isolated remote function view_my_bookingsContext(ViewMyBookingsRequest|ContextViewMyBookingsRequest req) returns ContextBookingStream|grpc:Error {
        map<string|string[]> headers = {};
        ViewMyBookingsRequest message;
        if req is ContextViewMyBookingsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("RentalService/view_my_bookings", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        BookingStream outputStream = new BookingStream(result);
        return {content: new stream<Booking, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class Create_usersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendCreateUserRequest(CreateUserRequest message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextCreateUserRequest(ContextCreateUserRequest message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveCreateUsersResponse() returns CreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <CreateUsersResponse>payload;
        }
    }

    isolated remote function receiveContextCreateUsersResponse() returns ContextCreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <CreateUsersResponse>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class PropertyStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Property value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Property value;|} nextRecord = {value: <Property>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public class BookingStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Booking value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Booking value;|} nextRecord = {value: <Booking>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public type ContextBookingStream record {|
    stream<Booking, error?> content;
    map<string|string[]> headers;
|};

public type ContextCreateUserRequestStream record {|
    stream<CreateUserRequest, error?> content;
    map<string|string[]> headers;
|};

public type ContextPropertyStream record {|
    stream<Property, error?> content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyResponse record {|
    UpdatePropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextBookPropertyRequest record {|
    BookPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextListPropertiesRequest record {|
    ListPropertiesRequest content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyRequest record {|
    UpdatePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchPropertyResponse record {|
    SearchPropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextCancelBookingResponse record {|
    CancelBookingResponse content;
    map<string|string[]> headers;
|};

public type ContextBooking record {|
    Booking content;
    map<string|string[]> headers;
|};

public type ContextConfirmBookingRequest record {|
    ConfirmBookingRequest content;
    map<string|string[]> headers;
|};

public type ContextConfirmBookingResponse record {|
    ConfirmBookingResponse content;
    map<string|string[]> headers;
|};

public type ContextViewMyBookingsRequest record {|
    ViewMyBookingsRequest content;
    map<string|string[]> headers;
|};

public type ContextAddPropertyResponse record {|
    AddPropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextRemovePropertyRequest record {|
    RemovePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextListHostPropertiesRequest record {|
    ListHostPropertiesRequest content;
    map<string|string[]> headers;
|};

public type ContextAddPropertyRequest record {|
    AddPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextCancelBookingRequest record {|
    CancelBookingRequest content;
    map<string|string[]> headers;
|};

public type ContextCreateUserRequest record {|
    CreateUserRequest content;
    map<string|string[]> headers;
|};

public type ContextRemovePropertyResponse record {|
    RemovePropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersResponse record {|
    CreateUsersResponse content;
    map<string|string[]> headers;
|};

public type ContextSearchPropertyRequest record {|
    SearchPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextProperty record {|
    Property content;
    map<string|string[]> headers;
|};

public type ContextBookPropertyResponse record {|
    BookPropertyResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type UpdatePropertyResponse record {|
    string message = "";
    boolean success = false;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type BookPropertyRequest record {|
    string property_id = "";
    string guest_id = "";
    string check_in = "";
    string check_out = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type ListPropertiesRequest record {|
    string location = "";
    float min_price = 0.0;
    float max_price = 0.0;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type UpdatePropertyRequest record {|
    string property_id = "";
    string property_name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type SearchPropertyResponse record {|
    string status = "";
    Property property = {};
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type Booking record {|
    string booking_id = "";
    string property_id = "";
    string guest_id = "";
    string check_in = "";
    string check_out = "";
    int number_of_nights = 0;
    float total_cost = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type CancelBookingResponse record {|
    string message = "";
    Booking booking = {};
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type ConfirmBookingRequest record {|
    string guest_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type ConfirmBookingResponse record {|
    string message = "";
    Booking booking = {};
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type ViewMyBookingsRequest record {|
    string guest_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type AddPropertyResponse record {|
    string property_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type RemovePropertyRequest record {|
    string property_id = "";
    string host_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type ListHostPropertiesRequest record {|
    string host_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type AddPropertyRequest record {|
    string property_name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string host_id = "";
    string status = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type CancelBookingRequest record {|
    string booking_id = "";
    string guest_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type CreateUserRequest record {|
    string name = "";
    string email = "";
    string role = "";
    string region = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type RemovePropertyResponse record {|
    string message = "";
    Property[] properties = [];
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type CreateUsersResponse record {|
    string message = "";
    int users_created = 0;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type SearchPropertyRequest record {|
    string property_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type Property record {|
    string property_id = "";
    string host_id = "";
    string property_name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type BookPropertyResponse record {|
    string message = "";
    boolean success = false;
|};
