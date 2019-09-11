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

import ballerina/http;
import ballerina/io;

# Object for Slack endpoint.
#
# + webhookUrl - Webhook URLs for Your Workspace
public type Client client object {

    public http:Client slackClient;

    public function __init(SlackConfiguration slackConfig) {
        self.slackClient = new(slackConfig.webhookUrl);
    }

    // Slack

    public remote function sendWebhookMessage(string messageType, string message, boolean markdown) returns @tainted string | error {
        http:Request req = new;

        string requestBody = "";

        if(messageType==TEXT_MESSAGE)
        {
            json jsPayload = {text : message, mrkdwn : markdown };
            req.setJsonPayload(jsPayload);
        }
        else
        {
            return "unknown_message_type";
        }

        var response = self.slackClient->post("",req);

        if (response is http:Response) {
            string contentType = response.getHeader("Content-Type");
            io:println("Content-Type: " + contentType);

            var res = response.getTextPayload();
            io:println("Response " + res.toString());

            int statusCode = response.statusCode;
            io:println("Status code: " + statusCode.toString());
            return res;
        } else {
             io:println("Error when calling the backend: " , response.reason());
             return "error";
        }
    }

};


# Slack Configuration.
#
# + webhookUrl - Webhook URLs for Your Workspace
public type SlackConfiguration record {
    string webhookUrl;
};
