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




        
    }






}