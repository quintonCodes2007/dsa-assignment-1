import ballerina/http;
import ballerina/time;
import ballerina/lang.regexp;



final regexp:RegExp SPACE_REGEX = re `\s+`;

//this function creates a 4-letter code from the names of the different input strings
function createCode(string value) returns string {
    string cleaned = value.toUpperAscii();
    cleaned = SPACE_REGEX.replaceAll(cleaned, "");

    if cleaned.length() >= 3 {
        return cleaned.substring(0, 4);
    }
    return cleaned;
}

//this function creates an asset tag from the previous functions codes
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
// CREATE ASSET
    resource function post .(Asset asset)
            returns http:Response|error {

        http:Response response = new;

        if assets.hasKey(asset.assetTag) {
            response.statusCode = 409;
            response.setPayload("Asset already exists");
            return response;
        }

        assets.put(asset);

        response.statusCode = 201;
        response.setPayload(asset);
        return response;
    }
 resource function post [string assetTag]/schedules(Schedule schedule)
        returns http:Response|error {

    http:Response response = new;

    foreach Asset asset in assets {
        if asset.assetTag == assetTag {
            asset.schedules.push(schedule);
            response.statusCode = 201;
            response.setPayload(schedule);
            return response;
        }
    }

    response.statusCode = 404;
    response.setPayload("Asset not found");
    return response;
}  
resource function get [string assetTag]/schedules()
        returns Schedule[]|http:Response|error {

    foreach Asset asset in assets {
        if asset.assetTag == assetTag {
            return asset.schedules;
        }
    }

    http:Response response = new;
    response.statusCode = 404;
    response.setPayload("Asset not found");
    return response;
}
resource function delete [string assetTag]/schedules/[string scheduleId]()
        returns http:Response|error {

    http:Response response = new;

    foreach Asset asset in assets {
        if asset.assetTag == assetTag {

            Schedule[] newSchedules = [];

            foreach Schedule schedule in asset.schedules {
                if schedule.scheduleId != scheduleId {
                    newSchedules.push(schedule);
                }
            }

            if newSchedules.length() == asset.schedules.length() {
                response.statusCode = 404;
                response.setPayload("Schedule not found");
                return response;
            }
Asset updatedAsset = {
    assetTag: asset.assetTag,
    name: asset.name,
    description: asset.description,
    institution: asset.institution,
    site: asset.site,
    status: asset.status,
    dateAcquired: asset.dateAcquired,
    components: asset.components,
    schedules: newSchedules,
    workOrders: asset.workOrders
};

            assets.put(updatedAsset);

            response.statusCode = 200;
            response.setPayload("Schedule removed successfully");
            return response;
        }
    }

    response.statusCode = 404;
    response.setPayload("Asset not found");
    return response;
}
resource function put [string assetTag]/schedules/[string scheduleId](Schedule updatedSchedule)
        returns http:Response|error {

    http:Response response = new;

    foreach Asset asset in assets {
        if asset.assetTag == assetTag {
            foreach int i in 0 ..< asset.schedules.length() {
                if asset.schedules[i].scheduleId == scheduleId {
                    asset.schedules[i] = updatedSchedule;
                    response.statusCode = 200;
                    response.setPayload(updatedSchedule);
                    return response;
                }
            }
            response.statusCode = 404;
            response.setPayload("Schedule not found");
            return response;
        }
    }

    response.statusCode = 404;
    response.setPayload("Asset not found");
    return response;
}
resource function get schedules/overdue() returns json[]|error {
    json[] overdue = [];

    time:Utc now = time:utcNow();
    time:Civil civilNow = time:utcToCivil(now);

    string monthStr = civilNow.month < 10
        ? "0" + civilNow.month.toString()
        : civilNow.month.toString();

    string dayStr = civilNow.day < 10
        ? "0" + civilNow.day.toString()
        : civilNow.day.toString();

    string today = civilNow.year.toString()
        + "-" + monthStr
        + "-" + dayStr;

    foreach Asset asset in assets {
        foreach Schedule schedule in asset.schedules {
            if schedule.dueDate < today {
                overdue.push({
                    assetTag: asset.assetTag,
                    assetName: asset.name,
                    scheduleId: schedule.scheduleId,
                    dueDate: schedule.dueDate,
                    description: schedule.description
                });
            }
        }
    }

    return overdue;
}
}
