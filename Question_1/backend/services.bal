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

// ============================================================
// ASSET SERVICE
// Base URL: http://localhost:8080/assets
// ============================================================

service /assets on new http:Listener(8080) {

    // --------------------------------------------------------
    // CREATE ASSET
    // POST /assets
    // --------------------------------------------------------
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

    // --------------------------------------------------------
    // VIEW ALL ASSETS / SEARCH BY INSTITUTION
    // GET /assets
    // GET /assets?institution=...
    // --------------------------------------------------------
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

    // --------------------------------------------------------
    // VIEW ONE ASSET
    // GET /assets/{assetTag}
    // --------------------------------------------------------
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

    // --------------------------------------------------------
    // DELETE ASSET
    // DELETE /assets/{assetTag}
    // --------------------------------------------------------
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

    // --------------------------------------------------------
    // Update ASSET
    // PUT /assets/{assetTag}
    // --------------------------------------------------------
    resource function put [string assetTag](@http:Payload Asset updatedAsset) returns http:Response {
        if !assets.hasKey(assetTag) {
            io:println("Asset update failed: tag ", assetTag, " not found");
            return errorResponse(404, "Asset not found");
        }

        Asset newAsset = {
            assetTag: assetTag,
            name: updatedAsset.name,
            description: updatedAsset.description,
            institution: updatedAsset.institution,
            site: updatedAsset.site,
            status: updatedAsset.status,
            dateAcquired: updatedAsset.dateAcquired,
            components: updatedAsset.components,
            schedules: updatedAsset.schedules,
            workOrders: updatedAsset.workOrders
        };
        assets.put(newAsset);

        io:println("Asset ", newAsset.name, " updated with tag ", assetTag);
        return successResponse(200, "Asset updated");
    }
=======
import ballerina/uuid;

function requireString(json|error value, string fieldName) returns string|http:BadRequest {
    if value is string {
        return value;
    }
    http:BadRequest err = {
        body: {"message": "'" + fieldName + "' is required and must be a string"}
    };
    return err;
}

service /assets on new http:Listener(8080) {

    // Update an asset
    resource function put [string assetTag](map<json> req) returns Asset|http:NotFound|http:BadRequest {
        Asset? existing = assets[assetTag];
        if existing is () {
            return http:NOT_FOUND;
        }

        Asset asset = existing;
>>>>>>> 387ab5558887bf5af1a2883e5ee1ac6590486dc5

        json|error name = req.name;
        if name is string {
            asset.name = name;
        }
        json|error description = req.description;
        if description is string {
            asset.description = description;
        }
        json|error institution = req.institution;
        if institution is string {
            asset.institution = institution;
        }
        json|error site = req.site;
        if site is string {
            asset.site = site;
        }
        json|error status = req.status;
        if status is string {
            asset.status = status;
        }
        json|error dateAcquired = req.dateAcquired;
        if dateAcquired is string {
            asset.dateAcquired = dateAcquired;
        }

    // --------------------------------------------------------
    // Loan ASSET
    // --------------------------------------------------------
    resource function post loans(@http:Payload Loan loan) returns http:Response {
        Asset? asset = assets[loan.assetTag];
        if asset is Asset {
            if asset.status != "AVAILABLE" {
                io:println("Loan creation failed: asset ", loan.assetTag, " is not available");
                return errorResponse(409, "Asset is not available for loan");
            }

            Loan newLoan = {
                loanId: "LOAN-" + time:utcToString(time:utcNow()),
                assetTag: loan.assetTag,
                borrower: loan.borrower,
                status: "ACTIVE",
                loanDate: loan.loanDate,
                dueDate: loan.dueDate
            };
            loans.put(newLoan);

            Asset updated = {
                assetTag: asset.assetTag,
                name: asset.name,
                description: asset.description,
                institution: asset.institution,
                site: asset.site,
                status: "LOANED_OUT",
                dateAcquired: asset.dateAcquired,
                components: asset.components,
                schedules: asset.schedules,
                workOrders: asset.workOrders
            };
            assets.put(updated);

            io:println("Loan ", newLoan.loanId, " created for asset ", loan.assetTag);
            return successResponse(201, "Loan created successfully");
        } else {
            io:println("Loan creation failed: asset ", loan.assetTag, " not found");
            return errorResponse(404, "Asset not found");
        }
    }


    // --------------------------------------------------------
    // return ASSET
    // --------------------------------------------------------
    resource function patch loans/[string loanId]/returnAsset() returns http:Response {
        Loan? loan = loans[loanId];
        if loan is Loan {
            if loan.status != "ACTIVE" {
                io:println("Return failed: loan ", loanId, " is not active");
                return errorResponse(409, "Loan is not active");
            }

            Loan updatedLoan = {
                loanId: loan.loanId,
                assetTag: loan.assetTag,
                borrower: loan.borrower,
                status: "RETURNED",
                loanDate: loan.loanDate,
                dueDate: loan.dueDate
            };
            loans.put(updatedLoan);

            Asset? asset = assets[loan.assetTag];
            if asset is Asset {
                Asset updated = {
                    assetTag: asset.assetTag,
                    name: asset.name,
                    description: asset.description,
                    institution: asset.institution,
                    site: asset.site,
                    status: "AVAILABLE",
                    dateAcquired: asset.dateAcquired,
                    components: asset.components,
                    schedules: asset.schedules,
                    workOrders: asset.workOrders
                };
                assets.put(updated);
            }

            io:println("Asset ", loan.assetTag, " returned, loan ", loanId, " closed");
            return successResponse(200, "Asset returned successfully");
        } else {
            io:println("Return failed: loan ", loanId, " not found");
            return errorResponse(404, "Loan not found");
        }
    }


    // --------------------------------------------------------
    // book ASSET
    // --------------------------------------------------------
    resource function post bookings(@http:Payload Booking booking) returns http:Response {
        Asset? asset = assets[booking.assetTag];
        if asset is Asset {
            if asset.status != "AVAILABLE" {
                io:println("Booking failed: asset ", booking.assetTag, " is not available");
                return errorResponse(409, "Asset is not available for booking");
            }

            Booking newBooking = {
                bookingId: "BOK-" + time:utcToString(time:utcNow()),
                assetTag: booking.assetTag,
                booker: booking.booker,
                date: booking.date,
                time: booking.time,
                status: "CONFIRMED"
            };
            bookings.put(newBooking);

            Asset updated = {
                assetTag: asset.assetTag,
                name: asset.name,
                description: asset.description,
                institution: asset.institution,
                site: asset.site,
                status: "OCCUPIED",
                dateAcquired: asset.dateAcquired,
                components: asset.components,
                schedules: asset.schedules,
                workOrders: asset.workOrders
            };
            assets.put(updated);

            io:println("Booking ", newBooking.bookingId, " created for asset ", booking.assetTag);
            return successResponse(201, "Booking created successfully");
        } else {
            io:println("Booking failed: asset ", booking.assetTag, " not found");
            return errorResponse(404, "Asset not found");
        }
    }
        assets.put(asset);
        return asset;
    }

    //  Loan an asset
    resource function post [string assetTag]/loans(map<json> req) returns Loan|http:NotFound|http:BadRequest {
        Asset? existing = assets[assetTag];
        if existing is () {
            return http:NOT_FOUND;
        }

        Asset asset = existing;

        // Asset must be AVAILABLE before it can be loaned out
        if asset.status != "AVAILABLE" {
            http:BadRequest err = {
                body: {"message": "Asset is not available for loan (current status: " + asset.status + ")"}
            };
            return err;
        }

        // 'borrower' and 'dueDate' are required
        string|http:BadRequest borrower = requireString(req.borrower, "borrower");
        if borrower is http:BadRequest {
            return borrower;
        }
        string|http:BadRequest dueDate = requireString(req.dueDate, "dueDate");
        if dueDate is http:BadRequest {
            return dueDate;
        }

        // Create the loan record
        Loan loan = {
            loanId: uuid:createType1AsString(),
            assetTag: assetTag,
            borrower: borrower,
            loanDate: time:utcToString(time:utcNow()),
            dueDate: dueDate,
            status: "ACTIVE"
        };

        loans.add(loan);

        // Reflect the new state on the asset after it has been loaned
        asset.status = "LOANED_OUT";
        assets.put(asset);

        return loan;
    }

    // Return a loaned asset
    resource function put loans/[string loanId]/returnAsset() returns Loan|http:NotFound|http:BadRequest {
        Loan? existing = loans[loanId];
        if existing is () {
            return http:NOT_FOUND;
        }

        Loan loan = existing;

        // Only an ACTIVE loan can be returned
        if loan.status != "ACTIVE" {
            http:BadRequest err = {
                body: {"message": "Loan is not active (current status: " + loan.status + ")"}
            };
            return err;
        }

        // Mark the loan as returned
        loan.status = "RETURNED";
        loans.put(loan);

        // Asset becomes AVAILABLE again
        Asset? assetEntry = assets[loan.assetTag];
        if assetEntry is Asset {
            assetEntry.status = "AVAILABLE";
            assets.put(assetEntry);
        }

        return loan;
    }

    // Book an asset
    resource function post [string assetTag]/bookings(map<json> req) returns Booking|http:NotFound|http:BadRequest {
        Asset? existing = assets[assetTag];
        if existing is () {
            return http:NOT_FOUND;
        }

        Asset asset = existing;

        // Asset must be available before it can be booked
        if asset.status != "AVAILABLE" {
            http:BadRequest err = {
                body: {"message": "Asset is not available for booking (current status: " + asset.status + ")"}
            };
            return err;
        }

        // 'booker', 'date' and 'time' are required
        string|http:BadRequest booker = requireString(req.booker, "booker");
        if booker is http:BadRequest {
            return booker;
        }
        string|http:BadRequest date = requireString(req.date, "date");
        if date is http:BadRequest {
            return date;
        }
        string|http:BadRequest time = requireString(req.time, "time");
        if time is http:BadRequest {
            return time;
        }

        // Create the booking record
        Booking booking = {
            bookingId: uuid:createType1AsString(),
            assetTag: assetTag,
            booker: booker,
            date: date,
            time: time,
            status: "CONFIRMED"
        };

        bookings.add(booking);

        // Reflect the new state on the asset
        asset.status = "OCCUPIED";
        assets.put(asset);

        return booking;
    }

}
}