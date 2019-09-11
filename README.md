[![Build Status])
​
# Slack Connector
​
The Slack connector allows you to send slack message through the Slack REST API.
​
## Compatibility
​
| Ballerina Language Version  | Slack API Version        |
|:---------------------------:|:------------------------:|
| 1.0.0                       | v1                       |
​
## Getting started
​
1.  Refer the [Getting Started](https://ballerina.io/learn/getting-started/) guide to download and install Ballerina.
​
2.  To use Slack endpoint, you need to provide the following:
​
       - Webhook URL
​
3. Create a new Ballerina project by executing the following command.
​
	```shell
	<PROJECT_ROOT_DIRECTORY>$ ballerina new <project_name>
	```
​
4. Import the Slack module to your Ballerina program as follows.
​
	```ballerina
	import ballerina/config;
	import ballerina/io;
    import hackbros/slack;
​
    slack:SlackConfiguration slackConfig = {
    webhookUrl: config:getAsString("WEBHOOK_Url")
    };
    slack:Client slackClient = new(slackConfig);
​
    public function main() {
​
        slack:SlackConfiguration slackConfig = {
            webhookUrl: "https://hooks.slack.com/services/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"
        };
​
        slack:Client slackClient = new(slackConfig);
​
        string | error response = slackClient->sendWebhookMessage("text","*hello balleria from hackbros*",false);
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