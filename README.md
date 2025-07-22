# Terraform Up & Running - Practice code

This code is used for practicing the chapters described in the book Terraform Up & Running by Yevgeniy Brikman.

## GitHub Repository

Since the book was writen in 2022, some changes have been made in the way Terraform is calling the AWS API, as well as other stuff that has been tested in July 2025.

The [GitHub](https://github.com/iuli72an/terraformbook) repository has been updated with latest changes, as it can be seen in the commit messages.

## Terraform setup

### Local setup
My local setup is a MacBook Pro 2017 with 16GB and 500GB SSD (Intel CPU).
The `terraform` binary has been installed using `brew` command:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

The current version of Terraform is:

```bash
Terraform v1.12.2
on darwin_amd64
```

# 🔐 Securely Store AWS Credentials Using GPG (No Ansible Vault Required)

This guide explains how to securely store and load AWS environment variables using **GPG encryption only**, without relying on Ansible Vault. This method works perfectly with tools like **Terraform**, **AWS CLI**, or any other infrastructure automation tool.

---

## 🧾 Step 1: Create the AWS Environment File

Create a file to hold your AWS credentials:

```bash
nano ~/.aws-env.rc
```

Add the following content (replace with your actual credentials):

```bash
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJatrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=eu-central-1
```

---

## 🔒 Step 2: Encrypt the File Using GPG

Encrypt the file with a passphrase:

```bash
gpg -c ~/.aws-env.rc
```

This creates the file `~/.aws-env.rc.gpg`.

Delete the original plain-text file:

```bash
shred -u ~/.aws-env.rc
```

---

## 🗝️ Step 3: Create a Loader Script

This script will decrypt and load the variables into your current shell session.

```bash
nano ~/.load_aws_env
```

Paste the following:

```bash
#!/bin/bash
# Decrypt and load AWS environment variables into current shell

gpg -q -d ~/.aws-env.rc.gpg | source /dev/stdin
```

Make the script executable:

```bash
chmod +x ~/.load_aws_env
```

---

## ⚙️ Step 4: Load AWS Credentials When Needed

Run this command in any terminal session where you need AWS access:

```bash
source ~/.load_aws_env
```

You'll be prompted for your GPG passphrase, and the credentials will be loaded as environment variables.

---

## ✅ Works With

- ✅ Terraform
- ✅ AWS CLI
- ✅ Python/Boto3
- ✅ Shell scripts
- ✅ Any infrastructure tool that reads from environment variables

---

## 🛡️ Benefits

- No plain-text secrets on disk
- Uses strong GPG encryption
- Easy to load and unload on demand
- No need for Ansible or Vault

---

## 🧠 Optional: Use GPG Agent

If you use `gpg-agent`, you won’t need to type the passphrase every time. It will cache the key for a set duration.

To check if agent is running:

```bash
gpg-agent
```

To enable it permanently, refer to the GPG documentation.

Have fun!