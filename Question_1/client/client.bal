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
            string assetTag = io:readln("Enter asset tag: ");
            string scheduleId = io:readln("Enter schedule ID: ");
            string scheduleType = io:readln("Enter schedule type: ");
            string dueDate = io:readln("Enter due date (YYYY-MM-DD): ");
            string description = io:readln("Enter description: ");

            json schedule = {
                scheduleId: scheduleId,
                scheduleType: scheduleType,
                dueDate: dueDate,
                description: description
            };

            http:Response response = check backendClient->post(
                "/assets/" + assetTag + "/schedules",
                schedule
            );

            io:println("Response status: ", response.statusCode);

if response.statusCode == 201 {
    io:println("Schedule added successfully.");
} else {
    io:println("Failed to add schedule.");
}

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
    string dueDate = io:readln("Enter new due date (YYYY-MM-DD): ");
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
    io:println("Update completed.");

        } else if choice == "4" {
    string assetTag = io:readln("Enter asset tag: ");
    string scheduleId = io:readln("Enter schedule ID: ");

    http:Response response = check backendClient->delete(
        "/assets/" + assetTag + "/schedules/" + scheduleId
    );

    io:println("Response status: ", response.statusCode);
    io:println("Delete completed.");

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