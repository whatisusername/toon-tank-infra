# Toon Tank Infrastructure

An online multiplayer tank battle game built on AWS, designed to deliver a seamless gaming experience and a highly scalable backend architecture.

Features:

- Core Gameplay
  - Supports real-time online multiplayer battles for engaging gameplay.
  - Developed both client and server-side using Unreal Engine 5.
- Backend Development
  - Implements core systems such as user authentication (sign-up/sign-in), matchmaking, and room creation using Golang.
  - Integrates GameLift FleetIQ for efficient game server deployment and cost optimization.
- Cloud Architecture
  - Designed a serverless architecture leveraging AWS services including Lambda Functions, API Gateway, DynamoDB, and RDS to ensure high availability and scalability.
  - Employed Terraform for infrastructure-as-code (IaC), enabling consistent and automated multi-environment deployments.
- CI/CD
  - Built a CI/CD pipeline using GitHub Actions to streamline development workflows, ensure quick iterations, and automate deployment processes.

## Installation

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
