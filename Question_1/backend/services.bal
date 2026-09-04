import ballerina/http;

// ===============================
// MAP DATABASE
// assetTag is the unique key
// ===============================

map<Asset> assetDB = {};

// ===============================
// REST SERVICE
// ===============================

service /asset on new http:Listener(8080) {

    // ===========================
    // CREATE ASSET
    // POST /asset/assets
    // ===========================

    resource function post assets(@http:Payload Asset asset)
            returns http:Created|http:BadRequest {

        if assetDB.hasKey(asset.assetTag) {
            return http:BAD_REQUEST;
        }

        assetDB[asset.assetTag] = asset;

        return http:CREATED;
    }

    // ===========================
    // VIEW ALL ASSETS
    // GET /asset/assets
    // ===========================

    resource function get assets() returns Asset[] {
        return assetDB.toArray();
    }

    // ===========================
    // SEARCH ASSET
    // GET /asset/assets/{assetTag}
    // ===========================

    resource function get assets/[string assetTag]()
            returns Asset|http:NotFound {

        Asset? asset = assetDB[assetTag];

        if asset is Asset {
            return asset;
        }

        return http:NOT_FOUND;
    }

    // ===========================
    // DELETE ASSET
    // DELETE /asset/assets/{assetTag}
    // ===========================

    resource function delete assets/[string assetTag]()
            returns http:Ok|http:NotFound {

        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }

        _ = assetDB.remove(assetTag);

        return http:OK;
    }
}
