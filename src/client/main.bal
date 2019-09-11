import ballerina/io;

import slack;

# Prints `Hello World`.

public function main() {

        slack:TwilioConfiguration twilioConfig = {
            accountSId: "AC1b6bfacc861f4082020fdfea8c181ee2",
            authToken: "ec3486d2302356af4d8b3dd0632bbc16",
            xAuthyKey: "871be22206402f2f170c1039d930cdc6"
        };

        slack:SlackConfiguration slackConfig = {
            webhookUrl: "https://hooks.slack.com/services/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"
        }

        slack:Client twilioClient = new(twilioConfig,slackConfig);

        var details = twilioClient->sendSms("+19282912134", "+16233300813", "hello ballerina");
        if (details is  slack:SmsResponse) {
        // If successful, print SMS Details.
            io:println("SMS Details: ", details);
        } else {
            // If unsuccessful, print the error returned.
            io:println("Error: ", details);
        }


    io:println("Hello World!");
}
