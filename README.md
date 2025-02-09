# Toon Tank Infrastructure

An online multiplayer tank battle game built on AWS, designed for seamless gameplay and a highly scalable backend architecture.

Features:

- Core Gameplay
  - Supports real-time online multiplayer battles for immersive and engaging gameplay.
  - Developed using Unreal Engine 5 for both the client and server sides.
- Backend Development
  - Implements user authentication (sign-up/sign-in), matchmaking, and room creation using Golang.
  - Integrates GameLift FleetIQ for efficient game server deployment and cost optimization.
  - All services are containerized for Lambda and EKS.
- Cloud Architecture
  - Designed a serverless architecture leveraging AWS Lambda, API Gateway, DynamoDB, and Aurora, ensuring high availability and scalability.
  - Uses Terraform for infrastructure-as-code (IaC), enabling consistent, automated multi-environment deployments.
- CI/CD
  - Implements a CI/CD pipeline using GitHub Actions to streamline development, ensure rapid iteration, and automate deployment processes.

Related GitHub Projects:

| Project Name | Description | Technologies |
|-|-|-|
| [toon-tank-user-service](https://github.com/whatisusername/toon-tank-user-service) | Manages user authentication and provides access tokens. | Golang, AWS Cognito, Secrets Manager |
| [toon-tank-post-signup-service](https://github.com/whatisusername/toon-tank-post-signup-service) | Implements a Cognito Post Confirmation Lambda Trigger, forwarding events to SQS for downstream processing. | Golang, AWS Cognito, SQS |
| [WIP] toon-tank-user-db-service | Securely stores user data in the database. | Golang, Aurora |

## Installation

### AWS

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

### make

- [Download mingw64](https://github.com/niXman/mingw-builds-binaries/releases/download/13.2.0-rt_v11-rev1/x86_64-13.2.0-release-win32-seh-msvcrt-rt_v11-rev1.7z)
- Extract files under `C:\Program Files`
- Add `C:\Program Files\mingw64\bin` to the system's environment variable `Path`
- Rename the executable under the `bin` folder from `mingw32-make` to `make`
- Verify the installation by running the following command in the Command Prompt:

  ```cmd
  make -v
  ```

### Terraform

- Download [Terraform](https://developer.hashicorp.com/terraform/install#windows)
- Extract the downloaded file to `C:\Program Files\HashiCorp\Terraform`
- Add the Terraform directory to your system's `Path` in the Environment Variables.
- Verify the installation by running the following command in the Command Prompt:

  ```cmd
  terraform version
  ```

## AWS Configuration Setup

We use **IAM Identity Center** to manage users and groups, so access keys are not enabled. To set up **SSO authentication locally**, please follow this [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html#cli-configure-sso-configure).

## Connect to the DB Instance via Bastion Host

To connect to the RDS instance using a Bastion Host, follow these steps:

- Deploy the `bastion-host`.
- Run the following command to establish a port forwarding session:

  ```cmd
  aws ssm start-session --target <ec2-instance-id> --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{\"host\":[\"<rds-endpoint>\"],\"portNumber\":[\"3306\"],\"localPortNumber\":[\"3306\"]}'
  ```

  - Replace `<ec2-instance-id>` with your Bastion Host's EC2 instance ID.
  - Replace `<rds-endpoint>` with the Aurora Cluster Writer Endpoint to ensure connectivity to the primary writable database instance.

- Open a database tool such as MySQL Workbench and connect to `localhost:3306`.
