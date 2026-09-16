import ballerina/http;
import ballerina/io;

public function main() returns error? {
    http:Client assetClient = check new ("http://localhost:8080");
    check runMenu(assetClient);
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

// ================= COMPONENT MENU =================

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
    

