import ballerina/http;
import ballerina/time;
import ballerina/uuid;

// Reads a required string field from the request body, returning a 400 error if it is missing or not a string
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

    // PUT /assets/{assetTag} — Update an asset (only fields sent in the body are changed)
    resource function put [string assetTag](map<json> req) returns Asset|http:NotFound|http:BadRequest {
        Asset? existing = assets[assetTag];
        if existing is () {
            return http:NOT_FOUND;
        }

        Asset asset = existing;

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

        assets.put(asset);
        return asset;
    }

    // POST /assets/{assetTag}/loans — Loan an asset
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

    // PUT /assets/loans/{loanId}/returnAsset — Return a loaned asset
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

    // POST /assets/{assetTag}/bookings — Book an asset
    resource function post [string assetTag]/bookings(map<json> req) returns Booking|http:NotFound|http:BadRequest {
        Asset? existing = assets[assetTag];
        if existing is () {
            return http:NOT_FOUND;
        }

        Asset asset = existing;

        // Asset must be AVAILABLE before it can be booked
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