import ballerina/io;

import slack;

# Prints `Hello World`.

public function main() {

        slack:SlackConfiguration slackConfig = {
            webhookUrl: "https://hooks.slack.com/services/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"
        };

        slack:Client twilioClient = new(slackConfig);

        string | error response = twilioClient->sendWebhookMessage("text","*hello balleria from hackbros*",false);
        if (response is  error) {
        // If unsuccessful, print error details
            io:println("Error in call to Slack: ", response);
        } else {
            if (response == "ok") {
                io:println("Slack Send Message is successful: ");
            }
            else {
            // If unsuccessful, print the error returned.
            io:println("Slack Error Code: ", response);
            }
        }

        string | error response1 = twilioClient->sendWebhookMessage("list","*hello balleria from hackbros*",false);
        if (response1 is  error) {
        // If unsuccessful, print error details
            io:println("Error in call to Slack: ", response1);
        } else {
            if (response1 == "ok") {
                io:println("Slack Send Message is successful: ");
            }
            else {
            // If unsuccessful, print the error returned.
            io:println("Slack Error Code: ", response1);
            }
        }
}
