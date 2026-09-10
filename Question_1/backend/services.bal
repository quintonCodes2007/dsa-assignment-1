import ballerina/http;
import ballerina/time;
import ballerina/lang.regexp;

final regexp:RegExp SPACE_REGEX = re `\s+`;

// Creates a code from the asset information
function createCode(string value) returns string {
    string cleaned = value.toUpperAscii();
    cleaned = SPACE_REGEX.replaceAll(cleaned, "");

    if cleaned.length() >= 3 {
        return cleaned.substring(0, 4);
    }

    return cleaned;
}

// Generates a unique asset tag
function generateAssetTag(string institution, string site, string name) returns string {
    string institutionCode = createCode(institution);
    string siteCode = createCode(site);
    string assetCode = createCode(name);

    int count = 0;

    foreach Asset asset in assets {
        if asset.institution == institution &&
           asset.site == site &&
           asset.name == name {
            count += 1;
        }
    }

    count += 1;

    string number = count.toString();

    while number.length() < 3 {
        number = "0" + number;
    }

    return institutionCode + "-" + siteCode + "-" + assetCode + "-" + number;
}


service /assets on new http:Listener(8080) {


    resource function post .(@http:Payload Asset asset) returns http:Response {

        string tag = asset.assetTag == ""
            ? generateAssetTag(asset.institution, asset.site, asset.name)
            : asset.assetTag;

        // Check whether the asset tag already exists
        if assets.hasKey(tag) {
            http:Response response = new;
            response.statusCode = 409;
            response.setPayload({
                message: "Asset already exists",
                assetTag: tag
            });
            return response;
        }

        Asset newAsset = {
            assetTag: tag,
            name: asset.name,
            description: asset.description,
            institution: asset.institution,
            site: asset.site,
            status: asset.status,
            dateAcquired: asset.dateAcquired
        };

        assets.add(newAsset);

        http:Response response = new;
        response.statusCode = 201;
        response.setPayload(newAsset);

        return response;
    }


    resource function get .(http:Request request) returns Asset[] {

        string? institution = request.getQueryParamValue("institution");

        Asset[] allAssets = assets.toArray();

        if institution is string {
            return from Asset asset in allAssets
                where asset.institution == institution
                select asset;
        }

        return allAssets;
    }


    resource function get [string assetTag]() returns http:Response {

        Asset? asset = assets[assetTag];

        if asset is Asset {
            http:Response response = new;
            response.statusCode = 200;
            response.setPayload(asset);

            return response;
        }

        http:Response response = new;
        response.statusCode = 404;
        response.setPayload({
            message: "Asset not found",
            assetTag: assetTag
        });

        return response;
    }


    resource function delete [string assetTag]() returns http:Response {

        if !assets.hasKey(assetTag) {
            http:Response response = new;
            response.statusCode = 404;
            response.setPayload({
                message: "Asset not found",
                assetTag: assetTag
            });

            return response;
        }

        _ = assets.remove(assetTag);

        http:Response response = new;
        response.statusCode = 200;
        response.setPayload({
            message: "Asset deleted successfully",
            assetTag: assetTag
        });

        return response;
    }
resource function post [string assetTag]/workorders(@http:Payload WorkOrder workOrder) returns http:Response {
        Asset? asset = assets[assetTag];
        if asset is Asset {
            workOrder.orderId = "WO-" + time:utcToString(time:utcNow());
            workOrder.status = "OPEN";
            asset.workOrders.push(workOrder);
            assets.put(asset);

            io:println("Work order ", workOrder.orderId, " created for asset ", assetTag);
            return successResponse(201, "Work order created successfully");
        } else {
            io:println("Work order creation failed: asset ", assetTag, " not found");
            return errorResponse(404, "Asset not found");
        }
        resource function put [string assetTag]/workorders/[string orderId](@http:Payload WorkOrder updatedOrder) returns http:Response {
        Asset? asset = assets[assetTag];
        if asset is Asset {
            int idx = -1;
            foreach int i in 0 ..< asset.workOrders.length() {
                if asset.workOrders[i].orderId == orderId {
                    idx = i;
                    break;
                }
            }
            if idx == -1 {
                io:println("Work order update failed: ", orderId, " not found on asset ", assetTag);
                return errorResponse(404, "Work order not found");
            }
            updatedOrder.orderId = orderId;
            asset.workOrders[idx] = updatedOrder;
            assets.put(asset);

            io:println("Work order ", orderId, " updated on asset ", assetTag);
            return successResponse(200, "Work order updated successfully");
        } else {
            io:println("Work order update failed: asset ", assetTag, " not found");
            return errorResponse(404, "Asset not found");
        }
    }
    
    resource function patch [string assetTag]/workorders/[string orderId]/close() returns http:Response {
        Asset? asset = assets[assetTag];
        if asset is Asset {
            int idx = -1;
            foreach int i in 0 ..< asset.workOrders.length() {
                if asset.workOrders[i].orderId == orderId {
                    idx = i;
                    break;
                }
            }
            if idx == -1 {
                io:println("Work order close failed: ", orderId, " not found on asset ", assetTag);
                return errorResponse(404, "Work order not found");
            }
            asset.workOrders[idx].status = "CLOSED";
            assets.put(asset);

            io:println("Work order ", orderId, " closed on asset ", assetTag);
            return successResponse(200, "Work order closed successfully");
        } else {
            io:println("Work order close failed: asset ", assetTag, " not found");
            return errorResponse(404, "Asset not found");
        }
    }
 resource function post [string assetTag]/workorders/[string orderId]/tasks(@http:Payload Task task) returns http:Response {
        Asset? asset = assets[assetTag];
        if asset is Asset {
            int idx = -1;
            foreach int i in 0 ..< asset.workOrders.length() {
                if asset.workOrders[i].orderId == orderId {
                    idx = i;
                    break;
                }
            }
            if idx == -1 {
                io:println("Task creation failed: work order ", orderId, " not found on asset ", assetTag);
                return errorResponse(404, "Work order not found");
            }
            task.taskId = "TASK-" + time:utcToString(time:utcNow());
            asset.workOrders[idx].tasks.push(task);
            assets.put(asset);

            io:println("Task ", task.taskId, " added to work order ", orderId);
            return successResponse(201, "Task added successfully");
        } else {
            io:println("Task creation failed: asset ", assetTag, " not found");
            return errorResponse(404, "Asset not found");
        }
    }

  resource function delete [string assetTag]/workorders/[string orderId]/tasks/[string taskId]() returns http:Response {
        Asset? asset = assets[assetTag];
        if asset is Asset {
            int woIdx = -1;
            foreach int i in 0 ..< asset.workOrders.length() {
                if asset.workOrders[i].orderId == orderId {
                    woIdx = i;
                    break;
                }
            }
            if woIdx == -1 {
                io:println("Task removal failed: work order ", orderId, " not found on asset ", assetTag);
                return errorResponse(404, "Work order not found");
            }
            int taskIdx = -1;
            foreach int j in 0 ..< asset.workOrders[woIdx].tasks.length() {
                if asset.workOrders[woIdx].tasks[j].taskId == taskId {
                    taskIdx = j;
                    break;
                }
            }
            if taskIdx == -1 {
                io:println("Task removal failed: ", taskId, " not found on work order ", orderId);
                return errorResponse(404, "Task not found");
            }
            _ = asset.workOrders[woIdx].tasks.remove(taskIdx);
            assets.put(asset);

            io:println("Task ", taskId, " removed from work order ", orderId);
            return successResponse(200, "Task removed successfully");
        } else {
            io:println("Task removal failed: asset ", assetTag, " not found");
            return errorResponse(404, "Asset not found");
        }
    }

    }






}