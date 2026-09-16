import ballerina/http;
import ballerina/io;

public function main() returns error? {
    http:Client assetClient = check new ("http://localhost:8080");
    check runMenu(assetClient);
}

// MAIN MENU LOOP

function runMenu(http:Client assetClient) returns error? {
    boolean running = true;
    while running {
        printMainMenu();
        string choice = io:readln("Select an option: ");
        match choice {
            "1" => { check assetMenu(assetClient); }
            "2" => { check scheduleMenu(assetClient); }
            "3" => { check componentMenu(assetClient); }
            "4" => { check workOrderMenu(assetClient); }
            "5" => { check loanMenu(assetClient); }
            "6" => { check bookingMenu(assetClient); }
            "0" => {
                running = false;
                io:println("Goodbye!");
            }
            _ => { io:println("Invalid option, please try again."); }
        }
    }
}

function printMainMenu() {
    io:println("\n=========================================");
    io:println("        ASSET MANAGEMENT SYSTEM");
    io:println("=========================================");
    io:println("1. Asset Management");
    io:println("2. Schedules");
    io:println("3. Components");
    io:println("4. Work Orders & Tasks");
    io:println("5. Loans");
    io:println("6. Bookings");
    io:println("0. Exit");
    io:println("=========================================");
}

function handleResponse(http:Response response, string successMsg, string failMsg) {
    int code = response.statusCode;
    if code >= 200 && code < 300 {
        io:println("[OK] ", successMsg, " (status ", code, ")");
    } else {
        io:println("[FAILED] ", failMsg, " (status ", code, ")");
    }
}

function printAsset(json assetJson) {
    map<json> a = <map<json>>assetJson;

    io:println("-----------------------------------------");
    io:println("Asset Tag     : ", a["assetTag"].toString());
    io:println("Name          : ", a["name"].toString());
    io:println("Description   : ", a["description"].toString());
    io:println("Institution   : ", a["institution"].toString());
    io:println("Site          : ", a["site"].toString());
    io:println("Status        : ", a["status"].toString());
    io:println("Date Acquired : ", a["dateAcquired"].toString());

    json componentsJson = a["components"];
    json schedulesJson = a["schedules"];
    json workOrdersJson = a["workOrders"];

    int compCount = componentsJson is json[] ? componentsJson.length() : 0;
    int schedCount = schedulesJson is json[] ? schedulesJson.length() : 0;
    int woCount = workOrdersJson is json[] ? workOrdersJson.length() : 0;

    io:println("Components    : ", compCount, " item(s)");
    io:println("Schedules     : ", schedCount, " item(s)");
    io:println("Work Orders   : ", woCount, " item(s)");
    io:println("-----------------------------------------");
}

function printAssetList(json assetsJson) {
    if assetsJson is json[] {
        if assetsJson.length() == 0 {
            io:println("(no assets found)");
            return;
        }
        foreach json a in assetsJson {
            printAsset(a);
        }
    } else {
        io:println("(unexpected response format)");
    }
}

// ASSET MENU

function assetMenu(http:Client assetClient) returns error? {
    boolean back = false;
    while !back {
        io:println("\n----- ASSET MANAGEMENT -----");
        io:println("1. View all assets");
        io:println("2. View assets by institution");
        io:println("3. View single asset");
        io:println("4. Add new asset");
        io:println("5. Update asset");
        io:println("6. Delete asset");
        io:println("7. View overdue assets");
        io:println("0. Back to main menu");
        string choice = io:readln("Select an option: ");
        match choice {
            "1" => { check viewAllAssets(assetClient); }
            "2" => {
                string institution = io:readln("Institution (e.g. NUST, UNAM, IUM): ");
                check viewCampusAssets(assetClient, institution);
            }
            "3" => { check viewSingleAsset(assetClient); }
            "4" => { check addAsset(assetClient); }
            "5" => { check updateAsset(assetClient); }
            "6" => { check deleteAsset(assetClient); }
            "7" => { check viewOverdueAssets(assetClient); }
            "0" => { back = true; }
            _ => { io:println("Invalid option, please try again."); }
        }
    }
}

function viewAllAssets(http:Client assetClient) returns error? {
    http:Response response = check assetClient->get("/assets");
    json assets = check response.getJsonPayload();
    io:println("\n===== GLOBAL ASSET VIEW =====");
    printAssetList(assets);
}

function viewCampusAssets(http:Client assetClient, string institution) returns error? {
    string path = "/assets?institution=" + institution;
    http:Response response = check assetClient->get(path);
    json assets = check response.getJsonPayload();
    io:println("\n===== CAMPUS VIEW: ", institution, " =====");
    printAssetList(assets);
}

function viewSingleAsset(http:Client assetClient) returns error? {
    string assetTag = io:readln("Asset tag: ");
    http:Response response = check assetClient->get("/assets/" + assetTag);
    if response.statusCode == 200 {
        json asset = check response.getJsonPayload();
        io:println("\n===== ASSET: ", assetTag, " =====");
        printAsset(asset);
    } else {
        io:println("[FAILED] Asset not found (status ", response.statusCode, ")");
    }
}

function addAsset(http:Client assetClient) returns error? {
    io:println("\n--- Add New Asset ---");
    string name = io:readln("Name: ");
    string description = io:readln("Description (asset type, e.g. Laptop): ");
    string institution = io:readln("Institution: ");
    string site = io:readln("Site: ");
    string status = io:readln("Status (AVAILABLE, LOANED_OUT, etc.): ");
    string dateAcquired = io:readln("Date acquired (YYYY-MM-DD): ");

    json newAsset = {
        "assetTag": "",
        "name": name,
        "description": description,
        "institution": institution,
        "site": site,
        "status": status,
        "dateAcquired": dateAcquired,
        "components": [],
        "schedules": [],
        "workOrders": []
    };

    http:Response response = check assetClient->post("/assets", newAsset);
    handleResponse(response, "Asset created", "Could not create asset");
}

function updateAsset(http:Client assetClient) returns error? {
    string assetTag = io:readln("Asset tag to update: ");
    io:println("Enter new values below:");
    string name = io:readln("Name: ");
    string description = io:readln("Description: ");
    string institution = io:readln("Institution: ");
    string site = io:readln("Site: ");
    string status = io:readln("Status: ");
    string dateAcquired = io:readln("Date acquired (YYYY-MM-DD): ");

    json updatedAsset = {
        "assetTag": assetTag,
        "name": name,
        "description": description,
        "institution": institution,
        "site": site,
        "status": status,
        "dateAcquired": dateAcquired,
        "components": [],
        "schedules": [],
        "workOrders": []
    };

    http:Response response = check assetClient->put("/assets/" + assetTag, updatedAsset);
    handleResponse(response, "Asset updated", "Could not update asset");
}

function deleteAsset(http:Client assetClient) returns error? {
    string assetTag = io:readln("Asset tag to delete: ");
    http:Response response = check assetClient->delete("/assets/" + assetTag);
    handleResponse(response, "Asset deleted", "Could not delete asset");
}

function viewOverdueAssets(http:Client assetClient) returns error? {
    http:Response response = check assetClient->get("/assets/overdue");
    json overdue = check response.getJsonPayload();
    io:println("\n===== OVERDUE DASHBOARD =====");
    printAssetList(overdue);
}

// SCHEDULE MENU

function scheduleMenu(http:Client assetClient) returns error? {
    boolean back = false;
    while !back {
        io:println("\n----- SCHEDULES -----");
        io:println("1. Add schedule to asset");
        io:println("2. Remove schedule from asset");
        io:println("0. Back to main menu");
        string choice = io:readln("Select an option: ");
        match choice {
            "1" => { check addSchedule(assetClient); }
            "2" => { check deleteSchedule(assetClient); }
            "0" => { back = true; }
            _ => { io:println("Invalid option, please try again."); }
        }
    }
}

function addSchedule(http:Client assetClient) returns error? {
    string assetTag = io:readln("Asset tag: ");
    string scheduleType = io:readln("Schedule type (MAINTENANCE, INSPECTION, CALIBRATION): ");
    string dueDate = io:readln("Due date (YYYY-MM-DD): ");
    string description = io:readln("Description: ");

    json schedule = {
        "scheduleId": "",
        "scheduleType": scheduleType,
        "dueDate": dueDate,
        "description": description
    };

    http:Response response = check assetClient->post("/assets/" + assetTag + "/schedules", schedule);
    handleResponse(response, "Schedule added", "Could not add schedule");
}

function deleteSchedule(http:Client assetClient) returns error? {
    string assetTag = io:readln("Asset tag: ");
    string scheduleId = io:readln("Schedule ID: ");
    http:Response response = check assetClient->delete("/assets/" + assetTag + "/schedules/" + scheduleId);
    handleResponse(response, "Schedule removed", "Could not remove schedule");
}

// COMPONENT MENU

function componentMenu(http:Client assetClient) returns error? {
    boolean back = false;
    while !back {
        io:println("\n----- COMPONENTS -----");
        io:println("1. Add component to asset");
        io:println("2. Remove component from asset");
        io:println("0. Back to main menu");
        string choice = io:readln("Select an option: ");
        match choice {
            "1" => { check addComponent(assetClient); }
            "2" => { check deleteComponent(assetClient); }
            "0" => { back = true; }
            _ => { io:println("Invalid option, please try again."); }
        }
    }
}

function addComponent(http:Client assetClient) returns error? {
    string assetTag = io:readln("Asset tag: ");
    string name = io:readln("Component name: ");
    string description = io:readln("Component description: ");

    json component = {
        "compId": "",
        "name": name,
        "description": description
    };

    http:Response response = check assetClient->post("/assets/" + assetTag + "/components", component);
    handleResponse(response, "Component added", "Could not add component");
}

function deleteComponent(http:Client assetClient) returns error? {
    string assetTag = io:readln("Asset tag: ");
    string compId = io:readln("Component ID: ");
    http:Response response = check assetClient->delete("/assets/" + assetTag + "/components/" + compId);
    handleResponse(response, "Component removed", "Could not remove component");
}

