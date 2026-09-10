import ballerina/http;
import ballerina/io;

public function main() returns error? {

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
}
    
}

