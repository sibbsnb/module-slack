// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/auth;
import ballerina/http;
import ballerina/mime;

# Object for Twilio endpoint.
#
# + accountSId - Unique identifier of the account
# + xAuthyKey - Unique identifier of Authy API account
# + basicClient - HTTP client endpoint for basic api
# + authyClient - HTTP client endpoint for authy api
public type Client client object {

    public string accountSId;
    public string xAuthyKey;
    public http:Client basicClient;
    public http:Client authyClient;

    public function __init(TwilioConfiguration twilioConfig) {
        http:BasicAuthHandler basicAuthHandler = self.createAuthHandler(twilioConfig);
        var secureSocket = twilioConfig?.secureSocket;
        if (secureSocket is http:ClientSecureSocket) {
            self.basicClient = new (TWILIO_API_BASE_URL, config = {
                auth: {
                    authHandler: basicAuthHandler
                },
                secureSocket: secureSocket
            });
            self.authyClient = new (AUTHY_API_BASE_URL, config = {
                auth: {
                    authHandler: basicAuthHandler
                }
            });
        } else {
            self.basicClient = new (TWILIO_API_BASE_URL, config = {
                auth: {
                    authHandler: basicAuthHandler
                },
                secureSocket: {
                    disable: true
                }
            });
            self.authyClient = new (AUTHY_API_BASE_URL, config = {
                auth: {
                    authHandler: basicAuthHandler
                },
                secureSocket: {
                    disable: true
                }
            });
        }
        self.accountSId = twilioConfig.accountSId;
        self.xAuthyKey = twilioConfig.xAuthyKey;
    }

    # Initialize Twilio endpoint.
    #
    # + twilioConfig - Twilio configuraion
    # + return - outboundBasicAuthHandler
    public function createAuthHandler(TwilioConfiguration twilioConfig) returns http:BasicAuthHandler {
        auth:OutboundBasicAuthProvider outboundBasicAuthProvider = new ({
            username: twilioConfig.accountSId,
            password: twilioConfig.authToken
        });

        http:BasicAuthHandler outboundBasicAuthHandler = new (outboundBasicAuthProvider);
        return outboundBasicAuthHandler;
    }

    # Return account details of the given account-sid.
    #
    # + return - If success, returns account object with basic details, else returns error
    public remote function getAccountDetails() returns @tainted Account | error {
        string requestPath = TWILIO_ACCOUNTS_API + FORWARD_SLASH + self.accountSId + ACCOUNT_DETAILS;
        var response = self.basicClient->get(requestPath);
        json jsonResponse = check parseResponseToJson(response);
        return mapJsonToAccount(jsonResponse);
    }

    # Send SMS from the given account-sid.
    # + fromNo - Mobile number which the SMS should be send from
    # + toNo - Mobile number which the SMS should be received to
    # + message - Message body of the SMS
    # + return - If success, returns SMS response object with basic details, else returns error
    public remote function sendSms(string fromNo, string toNo, string message) returns @tainted SmsResponse | error {
        http:Request req = new;

        string requestBody = "";
        requestBody = check createUrlEncodedRequestBody(requestBody, FROM, fromNo);
        requestBody = check createUrlEncodedRequestBody(requestBody, TO, toNo);
        requestBody = check createUrlEncodedRequestBody(requestBody, BODY, message);
        req.setTextPayload(requestBody, contentType = mime:APPLICATION_FORM_URLENCODED);

        string requestPath = TWILIO_ACCOUNTS_API + FORWARD_SLASH + self.accountSId + SMS_SEND;
        var response = self.basicClient->post(requestPath, req);

        json jsonResponse = check parseResponseToJson(response);
        return mapJsonToSmsResponse(jsonResponse);
    }

    # Make a voice call from the given account-sid.
    # + fromNo - Mobile number which the voice call should be send from
    # + toNo - Mobile number which the voice call should be received to
    # + twiml - TwiML URL which the response of the voice call is stated
    # + return - If success, returns voice call response object with basic details, else returns error
    public remote function makeVoiceCall(string fromNo, string toNo, string twiml) returns @tainted VoiceCallResponse | error {
        http:Request req = new;

        string requestBody = "";
        requestBody = check createUrlEncodedRequestBody(requestBody, FROM, fromNo);
        requestBody = check createUrlEncodedRequestBody(requestBody, TO, toNo);
        requestBody = check createUrlEncodedRequestBody(requestBody, URL, twiml);
        req.setTextPayload(requestBody, contentType = mime:APPLICATION_FORM_URLENCODED);

        string requestPath = TWILIO_ACCOUNTS_API + FORWARD_SLASH + self.accountSId + VOICE_CALL;
        var response = self.basicClient->post(requestPath, req);
        json jsonResponse = check parseResponseToJson(response);
        return mapJsonToVoiceCallResponse(jsonResponse);
    }

    # Get the Authy app details.
    # + return - If success, returns Authy app response object with basic details, else returns error
    public remote function getAuthyAppDetails() returns @tainted AuthyAppDetailsResponse | error {
        http:Request req = new;
        req.addHeader(X_AUTHY_API_KEY, self.xAuthyKey);

        string requestPath = AUTHY_APP_API;
        var response = self.authyClient->get(requestPath, message = req);
        json jsonResponse = check parseResponseToJson(response);
        return mapJsonToAuthyAppDetailsResponse(jsonResponse);
    }

    # Add an user for Authy app.
    # + email - Email of the new user
    # + phone - Phone number of the new user
    # + countryCode - Country code of the new user
    # + return - If success, returns Authy user add response object with basic details, else returns error
    public remote function addAuthyUser(string email, string phone, string countryCode) returns @tainted AuthyUserAddResponse |
    error {
        http:Request req = new;
        req.addHeader(X_AUTHY_API_KEY, self.xAuthyKey);

        string requestBody = "";
        requestBody = check createUrlEncodedRequestBody(requestBody, "user[email]", email);
        requestBody = check createUrlEncodedRequestBody(requestBody, "user[cellphone]", phone);
        requestBody = check createUrlEncodedRequestBody(requestBody, "user[country_code]", countryCode);
        req.setTextPayload(requestBody, contentType = mime:APPLICATION_FORM_URLENCODED);

        string requestPath = AUTHY_USER_API + USER_ADD;
        var response = self.authyClient->post(requestPath, req);
        json jsonResponse = check parseResponseToJson(response);
        return mapJsonToAuthyUserAddRespones(jsonResponse);
    }

    # Get the user details of Authy for the given user-id.
    # + userId - Unique identifier of the user
    # + return - If success, returns Authy user status response object with basic details, else returns error
    public remote function getAuthyUserStatus(string userId) returns @tainted AuthyUserStatusResponse | error {
        http:Request req = new;
        req.addHeader(X_AUTHY_API_KEY, self.xAuthyKey);
        string requestPath = AUTHY_USER_API + FORWARD_SLASH + userId + USER_STATUS;
        var response = self.authyClient->get(requestPath, message = req);
        json jsonResponse = check parseResponseToJson(response);
        return mapJsonToAuthyUserStatusResponse(jsonResponse);
    }

    # Delete the user of Authy for the given user-id.
    # + userId - Unique identifier of the user
    # + return - If success, returns Authy user delete response object with basic details, else returns error
    public remote function deleteAuthyUser(string userId) returns @tainted AuthyUserDeleteResponse | error {
        http:Request req = new;
        req.addHeader(X_AUTHY_API_KEY, self.xAuthyKey);
        string requestPath = AUTHY_USER_API + FORWARD_SLASH + userId + USER_REMOVE;
        var response = self.authyClient->post(requestPath, req);
        json jsonResponse = check parseResponseToJson(response);
        return mapJsonToAuthyUserDeleteResponse(jsonResponse);
    }

    # Get the user secret of Authy user for the given user-id.
    # + userId - Unique identifier of the user
    # + return - If success, returns Authy user secret response object with basic details, else returns error
    public remote function getAuthyUserSecret(string userId) returns @tainted AuthyUserSecretResponse | error {
        http:Request req = new;
        req.addHeader(X_AUTHY_API_KEY, self.xAuthyKey);
        string requestPath = AUTHY_USER_API + FORWARD_SLASH + userId + USER_SECRET;
        var response = self.authyClient->post(requestPath, req);
        json jsonResponse = check parseResponseToJson(response);
        return mapJsonToAuthyUserSecretResponse(jsonResponse);
    }

    # Request OTP for the user of Authy via SMS for the given user-id.
    # + userId - Unique identifier of the user
    # + return - If success, returns Authy OTP response object with basic details, else returns error
    public remote function requestOtpViaSms(string userId) returns @tainted AuthyOtpResponse | error {
        http:Request req = new;
        req.addHeader(X_AUTHY_API_KEY, self.xAuthyKey);
        string requestPath = AUTHY_OTP_SMS_API + FORWARD_SLASH + userId;
        var response = self.authyClient->get(requestPath, message = req);
        json jsonResponse = check parseResponseToJson(response);
        return mapJsonToAuthyOtpResponse(jsonResponse);
    }

    # Request OTP for the user of Authy via call for the given user-id.
    # + userId - Unique identifier of the user
    # + return - If success, returns Authy OTP response object with basic details, else returns error
    public remote function requestOtpViaCall(string userId) returns @tainted AuthyOtpResponse | error {
        http:Request req = new;
        req.addHeader(X_AUTHY_API_KEY, self.xAuthyKey);
        string requestPath = AUTHY_OTP_CALL_API + FORWARD_SLASH + userId;
        var response = self.authyClient->get(requestPath, message = req);
        json jsonResponse = check parseResponseToJson(response);
        return mapJsonToAuthyOtpResponse(jsonResponse);
    }

    # Verify OTP for the user of Authy for the given user-id.
    # + userId - Unique identifier of the user
    # + token - The OTP token to be verified
    # + return - If success, returns Authy OTP verify response object with basic details, else returns error
    public remote function verifyOtp(string userId, string token) returns @tainted AuthyOtpVerifyResponse | error {
        http:Request req = new;
        req.addHeader(X_AUTHY_API_KEY, self.xAuthyKey);
        string requestPath = AUTHY_OTP_VERIFY_API + FORWARD_SLASH + token + FORWARD_SLASH + userId;
        var response = self.authyClient->get(requestPath, message = req);
        json jsonResponse = check parseResponseToJson(response);
        return mapJsonToAuthyOtpVerifyResponse(jsonResponse);
    }

    # Dummy function to pass the test cases
    function dummyFunction() returns @tainted () {}
};

# Twilio Configuration.
#
# + accountSId - Unique identifier of the account
# + authToken - The authentication token of the account
# + xAuthyKey - The authentication token for the Authy API
# + secureSocket - ???
public type TwilioConfiguration record {
    string accountSId;
    string authToken;
    string xAuthyKey;
    http:ClientSecureSocket secureSocket?;
};
