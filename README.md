# Project Name

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

