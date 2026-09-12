import ballerina/http;
import ballerina/io;

http:Client backendClient = check new ("http://localhost:8080");

public function main() returns error? {

    while true {
        io:println("\n===== MAINTENANCE SCHEDULE MANAGER =====");
        io:println("1. Add maintenance schedule");
        io:println("2. View maintenance schedules");
        io:println("3. Update maintenance schedule");
        io:println("4. Delete maintenance schedule");
        io:println("5. View overdue alerts");
        io:println("6. Exit");

        string choice = io:readln("Choose an option: ");

        if choice == "1" {
            check addSchedule(backendClient);

        } else if choice == "2" {
            string assetTag = io:readln("Enter asset tag: ");

            json result = check backendClient->get(
                "/assets/" + assetTag + "/schedules"
            );

            io:println("Maintenance schedules: ", result);

        } else if choice == "3" {
            string assetTag = io:readln("Enter asset tag: ");
            string scheduleId = io:readln("Enter schedule ID: ");
            string scheduleType = io:readln("Enter new schedule type: ");
            string dueDate = io:readln("Enter new due date: ");
            string description = io:readln("Enter new description: ");

            json updatedSchedule = {
                scheduleId: scheduleId,
                scheduleType: scheduleType,
                dueDate: dueDate,
                description: description
            };

            http:Response response = check backendClient->put(
                "/assets/" + assetTag + "/schedules/" + scheduleId,
                updatedSchedule
            );

            io:println("Response status: ", response.statusCode);

            if response.statusCode == 200 {
                io:println("Schedule updated successfully.");
            } else {
                io:println("Failed to update schedule.");
            }

        } else if choice == "4" {
            check deleteSchedule(backendClient);

        } else if choice == "5" {
            json overdue = check backendClient->get(
                "/assets/schedules/overdue"
            );

            io:println("\n--- Overdue Maintenance Alerts ---");
            io:println(overdue);

        } else if choice == "6" {
            io:println("Goodbye!");
            break;

        } else {
            io:println("Invalid option. Please choose 1-6.");
        }
    }
}

function addSchedule(http:Client assetClient) returns error? {

    string assetTag = io:readln("Asset tag: ");
    string scheduleType = io:readln(
        "Schedule type (MAINTENANCE, INSPECTION, CALIBRATION): "
    );
    string dueDate = io:readln("Due date (YYYY-MM-DD): ");
    string description = io:readln("Description: ");

    json schedule = {
        "scheduleId": "",
        "scheduleType": scheduleType,
        "dueDate": dueDate,
        "description": description
    };

    http:Response response = check assetClient->post(
        "/assets/" + assetTag + "/schedules",
        schedule
    );

    io:println("Response status: ", response.statusCode);

    if response.statusCode == 201 {
        io:println("Schedule added successfully.");
    } else {
        io:println("Could not add schedule.");
    }
}

function deleteSchedule(http:Client assetClient) returns error? {

    string assetTag = io:readln("Asset tag: ");
    string scheduleId = io:readln("Schedule ID: ");

    http:Response response = check assetClient->delete(
        "/assets/" + assetTag + "/schedules/" + scheduleId
    );

    io:println("Response status: ", response.statusCode);

    if response.statusCode == 200 {
        io:println("Schedule removed successfully.");
    } else {
        io:println("Could not remove schedule.");
    }
}