# Dynamic HTML Page with Terraform and AWS 🚀

This project deploys a dynamic HTML page using **Terraform** and **AWS services** like Lambda, API Gateway, and SSM Parameter Store.  
The HTML content includes a string that can be updated without having to redeploy. ✅

---

## ✨ Features

- ✅ **Serverless architecture** using AWS Lambda
- ✅ **Public API** endpoint via API Gateway
- ✅ **Dynamic content** stored in Parameter Store
- ✅ **Fully managed with Terraform**
- ✅ Support for editing the text without redeployment

---

## 📦 Technologies Used

- [Terraform](https://terraform.io)
- AWS Lambda (Python 3.11)
- AWS API Gateway
- AWS Systems Manager (SSM) Parameter Store

---

## 🚀 How to Deploy

Ensure you have AWS CLI and Terraform installed (and configured using SSO or environment variables).

```bash
terraform init
terraform apply
