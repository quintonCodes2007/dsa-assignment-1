import ballerina/http;
import ballerina/time;
import ballerina/uuid;

type UpdateAssetRequest record {
    string name?;
    string description?;
    string institution?;
    string site?;
    string status?;
    string dateAcquired?;
};

type LoanRequest record {
    string borrower;
    string dueDate;
};

type BookRequest record {
    string booker;
    string date;
    string time;
};

// ── Service ──

service /assets on new http:Listener(8080) {

    // PUT /assets/{assetTag} — Update an asset
    resource function put [string assetTag](UpdateAssetRequest req) returns Asset|http:NotFound|http:BadRequest {
        Asset? existing = assets[assetTag];
        if existing is () {
            return http:NOT_FOUND;
        }

        Asset asset = existing;

        if req.name is string {
            asset.name = <string>req.name;
        }
        if req.description is string {
            asset.description = <string>req.description;
        }
        if req.institution is string {
            asset.institution = <string>req.institution;
        }
        if req.site is string {
            asset.site = <string>req.site;
        }
        if req.status is string {
            asset.status = <string>req.status;
        }
        if req.dateAcquired is string {
            asset.dateAcquired = <string>req.dateAcquired;
        }

        assets.put(asset);
        return asset;
    }

    // POST /assets/{assetTag}/loans — Loan an asset
    resource function post [string assetTag]/loans(LoanRequest req) returns Loan|http:NotFound|http:BadRequest {
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

        // Create the loan record
        Loan loan = {
            loanId: uuid:createType1AsString(),
            assetTag: assetTag,
            borrower: req.borrower,
            loanDate: time:utcToString(time:utcNow()),
            dueDate: req.dueDate,
            status: "ACTIVE"
        };

        loans.add(loan);

        // Reflect the new state on the asset aftre it has been loaned
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
    resource function post [string assetTag]/bookings(BookRequest req) returns Booking|http:NotFound|http:BadRequest {
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

        // Create the booking record
        Booking booking = {
            bookingId: uuid:createType1AsString(),
            assetTag: assetTag,
            booker: req.booker,
            date: req.date,
            time: req.time,
            status: "CONFIRMED"
        };

        bookings.add(booking);

        // Reflect the new state on the asset
        asset.status = "OCCUPIED";
        assets.put(asset);

        return booking;
    }
}
