import ballerina/io;

import slack;

# Prints `Hello World`.

public function main() {

        slack:SlackConfiguration slackConfig = {
            webhookUrl: "https://hooks.slack.com/services/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"
        };

        slack:Client twilioClient = new(slackConfig);

        var response = twilioClient->sendWebhookMessage("*hello*",false);

    io:println("Hello World!");
}
