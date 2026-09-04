import ballerina/http;
import ballerina/time;
import ballerina/lang.regexp;



final regexp:RegExp SPACE_REGEX = re `\s+`;

//this function creates a 3-letter code from the names of the different input strings
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

   

}     



