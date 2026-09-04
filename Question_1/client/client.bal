import ballerina/http;
import ballerina/io;

// ===============================
// DATA TYPES
// ===============================

type Status "AVAILABLE"|"UNDER_REPAIR"|"DISPOSED";

type Asset record {|
    string assetTag;
    string name;
    string description;
    string institution;
    string site;
    Status status;
    string dateAcquired;
|};

// ===============================
// MAIN CLIENT
// ===============================

public function main() returns error? {

    http:Client api = check new ("http://localhost:8080");

    boolean running = true;

    io:println("=======================================");
    io:println(" LIBRARY & RESOURCE MANAGEMENT SYSTEM");
    io:println("=======================================");

    while running {

        io:println("\n============== MENU ==============");
        io:println("1.  Create Asset");
        io:println("2.  View All Assets");
        io:println("3.  Search Asset");
        io:println("4.  Delete Asset");
        io:println("0.  Exit");
        io:println("=================================");

        string choice = check readInput("Enter your choice: ");

        match choice {

            // ==========================
            // CREATE
            // ==========================

            "1" => {

                io:println("\n=== CREATE NEW ASSET ===");

                string assetTag =
                    check readInput("Asset Tag: ");

                string name =
                    check readInput("Name: ");

                string description =
                    check readInput("Description: ");

                string institution =
                    check readInput("Institution: ");

                string site =
                    check readInput("Site/Campus: ");

                string statusInput =
                    check readInput(
                        "Status (AVAILABLE/UNDER_REPAIR/DISPOSED): "
                    );

                string dateAcquired =
                    check readInput("Date Acquired (YYYY-MM-DD): ");

                Asset asset = {
                    assetTag: assetTag,
                    name: name,
                    description: description,
                    institution: institution,
                    site: site,
                    status: <Status>statusInput,
                    dateAcquired: dateAcquired
                };

                http:Response response =
                    check api->post("/asset/assets", asset);

                if response.statusCode == 201 {
                    io:println("Asset created successfully.");
                } else if response.statusCode == 400 {
                    io:println(
                        "Asset could not be created. " +
                        "The assetTag may already exist."
                    );
                } else {
                    io:println(
                        "Error creating asset: " +
                        response.statusCode.toString()
                    );
                }
            }

            // ==========================
            // VIEW ALL
            // ==========================

            "2" => {

                io:println("\n=== ALL ASSETS ===");

                Asset[] assets =
                    check api->get("/asset/assets");

                if assets.length() == 0 {
                    io:println("No assets found.");
                } else {

                    foreach Asset asset in assets {

                        io:println(
                            "\nAsset Tag: " + asset.assetTag
                        );

                        io:println(
                            "Name: " + asset.name
                        );

                        io:println(
                            "Description: " + asset.description
                        );

                        io:println(
                            "Institution: " + asset.institution
                        );

                        io:println(
                            "Site: " + asset.site
                        );

                        io:println(
                            "Status: " + asset.status.toString()
                        );

                        io:println(
                            "Date Acquired: " + asset.dateAcquired
                        );
                    }
                }
            }

            // ==========================
            // SEARCH
            // ==========================

            "3" => {

                string assetTag =
                    check readInput("Enter asset tag: ");

                http:Response response =
                    check api->get(
                        "/asset/assets/" + assetTag
                    );

                if response.statusCode == 200 {

                    json payload =
                        check response.getJsonPayload();
                    Asset asset =
                        check payload.cloneWithType(Asset);

                    io:println("\n=== ASSET DETAILS ===");

                    io:println(
                        "Asset Tag: " + asset.assetTag
                    );

                    io:println(
                        "Name: " + asset.name
                    );

                    io:println(
                        "Description: " + asset.description
                    );

                    io:println(
                        "Institution: " + asset.institution
                    );

                    io:println(
                        "Site/Campus: " + asset.site
                    );

                    io:println(
                        "Status: " + asset.status.toString()
                    );

                    io:println(
                        "Date Acquired: " + asset.dateAcquired
                    );

                } else {
                    io:println("Asset not found.");
                }
            }

            // ==========================
            // DELETE
            // ==========================

            "4" => {

                string assetTag =
                    check readInput("Enter asset tag to delete: ");

                http:Response response =
                    check api->delete(
                        "/asset/assets/" + assetTag
                    );

                if response.statusCode == 200 {
                    io:println("Asset deleted successfully.");
                } else {
                    io:println("Asset not found.");
                }
            }

            // ==========================
            // EXIT
            // ==========================

            "0" => {

                io:println(
                    "\nThank you for using the " +
                    "Library & Resource Management System."
                );

                running = false;
            }

            _ => {
                io:println(
                    "Invalid option. Please choose 0-4."
                );
            }
        }
    }
}

// ===============================
// INPUT HELPER
// ===============================

function readInput(string prompt) returns string|error {

    io:print(prompt);

    string|error input = io:readln();

    if input is string {
        return input;
    }

    return input;
}
