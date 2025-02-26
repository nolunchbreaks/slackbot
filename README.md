# ChatOps Slack Bot Project

## Description

This project involves creating a ChatOps Slack bot that integrates with AWS CloudWatch to alert engineers about incidents and allows them to trigger remediation actions directly from Slack. The bot is developed using Python and leverages AWS Lambda for serverless deployment.

## Features

- **Automated Alerts**: Receives and sends alerts from AWS CloudWatch to designated Slack channels.
- **Command Execution**: Enables engineers to execute predefined remediation commands from Slack.
- **Integration with Monitoring Tools**: Seamlessly integrates with AWS CloudWatch and can be extended to work with Prometheus.
- **Optional PagerDuty Integration**: Supports escalation by integrating with PagerDuty.

## Prerequisites

Before setting up the bot, ensure you have the following:

- **AWS Account**: Active account with permissions to create Lambda functions, API Gateway, IAM roles, and CloudWatch alarms.
- **Slack Workspace**: Administrative access to create and configure a Slack App.
- **Python 3.x**: Installed on your local development machine.
- **Terraform**: Installed for infrastructure as code deployment.

## Installation

1. **Clone the Repository**:
   ```sh
   git clone https://github.com/yourusername/chatops-terraform.git
   cd chatops-terraform
   ```

2. **Set Up Python Environment**:
   - Create a virtual environment:
     ```sh
     python3 -m venv venv
     ```
   - Activate the virtual environment:
     ```sh
     source venv/bin/activate
     ```
   - Install dependencies:
     ```sh
     pip install -r requirements.txt
     ```

3. **Configure Slack App**:
   - Create a new Slack App in your workspace via the [Slack API](https://api.slack.com/apps).
   - Enable **Event Subscriptions** and set the request URL to the API Gateway endpoint (to be created).
   - Subscribe to bot events as needed (e.g., `message.channels`, `app_mention`).
   - Install the app to your workspace and obtain the **Bot User OAuth Token** and **Signing Secret**.

4. **Set Up Environment Variables**:
   - Create a `.env` file in the project root:
     ```env
     SLACK_BOT_TOKEN=your-slack-bot-token
     SLACK_SIGNING_SECRET=your-slack-signing-secret
     ```

5. **Initialize Terraform**:
   - Initialize Terraform:
     ```sh
     terraform init
     ```
   - Apply the Terraform configuration to deploy resources:
     ```sh
     terraform apply
     ```
   - During the apply process, input necessary variables such as `aws_region`, `slack_bot_token`, and `slack_signing_secret` when prompted.

## Usage

Once deployed, the bot will automatically listen for events in your Slack workspace. You can interact with the bot by:

- Sending direct messages.
- Mentioning the bot in channels.
- Using predefined slash commands.

The bot will process these interactions and execute corresponding actions, such as triggering AWS Lambda functions or sending responses back to Slack.

## Deployment

This project utilizes Terraform to automate the deployment of AWS resources. The infrastructure includes:

- **AWS Lambda Function**: Hosts the bot's code.
- **API Gateway**: Handles HTTP requests from Slack.
- **IAM Roles and Policies**: Manage permissions for AWS services.
- **SNS Topic**: Facilitates communication between CloudWatch and the bot.
- **CloudWatch Alarms**: Monitor AWS resources and send alerts.

To deploy, ensure your AWS credentials are configured, then run:
```sh
terraform apply
```
This command will provision all necessary resources and output the API Gateway endpoint URL, which should be configured in your Slack App settings.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch:
   ```sh
   git checkout -b feature-name
   ```
3. Make your changes and commit them:
   ```sh
   git commit -m "Description of changes"
   ```
4. Push to the branch:
   ```sh
   git push origin feature-name
   ```
5. Open a pull request detailing your changes.

## License

This project is licensed under the MIT License.

