import ballerina/http;
import ballerina/io;

const string BASE_URL = "http://localhost:8080/assets";

public function main() returns error? {
    http:Client assetClient = check new (BASE_URL);

    boolean running = true;

    while running {
        io:println("\n========================================");
        io:println("       ASSET MANAGEMENT SYSTEM");
        io:println("========================================");
        io:println("1. Update Asset");
        io:println("2. Loan Asset");
        io:println("3. Return Asset");
        io:println("4. Book Asset");
        io:println("5. Exit");
        io:println("========================================");
        io:print("Select an option: ");

        string choice = io:readln();

        match choice {
            "1" => {
                check handleUpdateAsset(assetClient);
            }
            "2" => {
                check handleLoanAsset(assetClient);
            }
            "3" => {
                check handleReturnAsset(assetClient);
            }
            "4" => {
                check handleBookAsset(assetClient);
            }
            "5" => {
                running = false;
                io:println("Goodbye!");
            }
            _ => {
                io:println("Invalid option. Please try again.");
            }
        }
    }
}

// ── 1. Update Asset
function handleUpdateAsset(http:Client hc) returns error? {
    io:println("\n--- Update Asset ---");
    io:print("Enter asset tag: ");
    string assetTag = io:readln();

    io:print("New name (leave empty to skip): ");
    string name = io:readln();

    io:print("New description (leave empty to skip): ");
    string description = io:readln();

    io:print("New institution (leave empty to skip): ");
    string institution = io:readln();

    io:print("New site (leave empty to skip): ");
    string site = io:readln();

    io:print("New status (leave empty to skip): ");
    string status = io:readln();

    io:print("New date acquired (leave empty to skip): ");
    string dateAcquired = io:readln();

    string payload = "{";
    boolean first = true;

    if name != "" {
        payload += "\"name\":\"" + name + "\"";
        first = false;
    }
    if description != "" {
        if !first { payload += ","; }
        payload += "\"description\":\"" + description + "\"";
        first = false;
    }
    if institution != "" {
        if !first { payload += ","; }
        payload += "\"institution\":\"" + institution + "\"";
        first = false;
    }
    if site != "" {
        if !first { payload += ","; }
        payload += "\"site\":\"" + site + "\"";
        first = false;
    }
    if status != "" {
        if !first { payload += ","; }
        payload += "\"status\":\"" + status + "\"";
        first = false;
    }
    if dateAcquired != "" {
        if !first { payload += ","; }
        payload += "\"dateAcquired\":\"" + dateAcquired + "\"";
    }

    payload += "}";

    http:Response resp = check hc->put("/" + assetTag, payload);

    if resp.statusCode == 200 {
        io:println("Asset updated successfully:");
        io:println(check resp.getTextPayload());
    } else if resp.statusCode == 404 {
        io:println("Error: Asset not found.");
    } else {
        io:println("Error: " + check resp.getTextPayload());
    }
}

// ── 2. Loan Asset
function handleLoanAsset(http:Client hc) returns error? {
    io:println("\n--- Loan Asset ---");
    io:print("Enter asset tag: ");
    string assetTag = io:readln();

    io:print("Enter borrower name: ");
    string borrower = io:readln();

    io:print("Enter due date (YYYY-MM-DD): ");
    string dueDate = io:readln();

    string payload = "{\"borrower\":\"" + borrower + "\",\"dueDate\":\"" + dueDate + "\"}";

    http:Response resp = check hc->post("/" + assetTag + "/loans", payload);

    if resp.statusCode == 200 || resp.statusCode == 201 {
        io:println("Loan created successfully:");
        io:println(check resp.getTextPayload());
    } else if resp.statusCode == 404 {
        io:println("Error: Asset not found.");
    } else {
        io:println("Error: " + check resp.getTextPayload());
    }
}

// ── 3. Return Asset
function handleReturnAsset(http:Client hc) returns error? {
    io:println("\n--- Return Asset ---");
    io:print("Enter loan ID: ");
    string loanId = io:readln();

    http:Response resp = check hc->put("/loans/" + loanId + "/returnAsset", "");

    if resp.statusCode == 200 {
        io:println("Asset returned successfully:");
        io:println(check resp.getTextPayload());
    } else if resp.statusCode == 404 {
        io:println("Error: Loan not found.");
    } else {
        io:println("Error: " + check resp.getTextPayload());
    }
}

// ── 4. Book Asset
function handleBookAsset(http:Client hc) returns error? {
    io:println("\n--- Book Asset ---");
    io:print("Enter asset tag: ");
    string assetTag = io:readln();

    io:print("Enter booker name: ");
    string booker = io:readln();

    io:print("Enter date (YYYY-MM-DD): ");
    string date = io:readln();

    io:print("Enter time (HH:MM): ");
    string time = io:readln();

    string payload = "{\"booker\":\"" + booker + "\",\"date\":\"" + date + "\",\"time\":\"" + time + "\"}";

    http:Response resp = check hc->post("/" + assetTag + "/bookings", payload);

    if resp.statusCode == 200 || resp.statusCode == 201 {
        io:println("Booking created successfully:");
        io:println(check resp.getTextPayload());
    } else if resp.statusCode == 404 {
        io:println("Error: Asset not found.");
    } else {
        io:println("Error: " + check resp.getTextPayload());
    }
}
