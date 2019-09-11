Connects to Slack from Ballerina. 
# Module Overview
The Slack connector allows you to send slack message through the Slack REST API.
**Basic Operations**
The `hackbros/slack` module contains operations to send messages to Slack
## Compatibility
|                          |    Version     |
|:------------------------:|:--------------:|
| Ballerina Language       | 1.0.0          |
| Slack API Version        | v1             |
## Sample
First, import the `hackbros/slack` module into the Ballerina project.
```ballerina
import hackbros/slack;
```
**Obtaining webhook URL to Run the Sample**
1. Visit [SLACK](https://api.slack.com/incoming-webhooks/) and create a Slack Account.
2. Obtain the webhook url
You can now enter the webhook url in the slack endpoint configuration.
```ballerina
slack:SlackConfiguration slackConfig = {
    webhookUrl: config:getAsString("WEBHOOK_Url")
};
sslack:Client slackClient = new(slackConfig);
```
The `sendWebhookMessage` remote function sends a slack message to a slack channel with the specified message.
```ballerina
string | error response = slackClient->sendWebhookMessage("*hello*",false);
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
}
```