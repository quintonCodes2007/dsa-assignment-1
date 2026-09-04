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


service /assets on new http:Listener(8080) {

   

}     



