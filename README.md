# 🚀 Internal Utility Service Deployment

## 📌 Overview

I built a small internal utility service and deployed it on AWS using Terraform and GitHub Actions.

This project shows how I automate infrastructure and application deployment using DevOps best practices.

👉 **Demo Video:**
https://drive.google.com/file/d/1RGXmrmWFTyCc5Y0g9Sre6Ta-wqeTReBH/view?usp=sharing

👉 **Architecture Diagram (draw.io):**
https://drive.google.com/file/d/1R5BAbxjbH-FYjUW5ZMR3ImkuicPfVFPY/view?usp=sharing

## 🏗️ Architecture

- AWS Lambda (Python 3.11)
- API Gateway (HTTP API)
- IAM Roles & Policies
- Terraform (Infrastructure as Code)
- GitHub Actions (CI/CD)

## 📂 Project Structure

```
terraform-gitactions/
├── .github/workflows/
│   ├── ci.yml          # CI pipeline
│   └── deploy.yml      # CD pipeline
├── app/
│   └── lambda_function.py
├── modules/
│   ├── api_gateway/
│   ├── iam/
│   └── lambda/
├── scripts/
│   └── package.sh
├── terraform/envs/prod/
└── README.md
```

## ⚙️ Application

I created a simple Lambda function:

```python
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "Hello from AWS - this is somasekhar jamalla"
    }
```

## 🌐 API Endpoint

**Method:** GET

**URL:**
```
https://<api-id>.execute-api.us-east-1.amazonaws.com/hello
```

## 🔄 CI/CD Pipeline

### ✅ CI Pipeline (Pull Requests)

I configured CI to:

- Run Terraform init
- Check Terraform formatting
- Validate Terraform code
- Run TFLint
- Run Flake8 (Python linting)
- Run Trivy (security scan)

### 🚀 CD Pipeline (Main Branch)

When I push to main:

- I package the Lambda function
- I run Terraform plan
- I apply infrastructure changes
- I deploy automatically to AWS

## 🧩 Challenges & Fixes

### 1. GitHub Actions Dependency Issue

**Problem:** Invalid `needs: deploy-dev`

**Fix:** I removed the dependency

### 2. CI Pipeline Issues

I fixed multiple problems:

- Wrong filename (`ci.yml ` → `ci.yml`)
- Terraform not installed → added setup step
- Invalid Trivy version → updated version
- Wrong working directory → fixed paths

### 3. Python Lint Error

**Issue:** Missing newline at end of file

**Fix:** I added a newline

## 🛠️ Setup Instructions

### Prerequisites

- AWS Account
- GitHub Account
- Terraform (optional for local testing)

### Steps

1. **Clone repository:**
   ```bash
   git clone https://github.com/jamallasomasekhar/terraform-gitactions.git
   ```

2. **Add GitHub Secrets:**
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

3. **Create Pull Request**
   → CI pipeline runs

4. **Merge to main**
   → CD pipeline deploys

5. **Access API**

## ⚠️ Note

My GitHub account reached the Actions usage limit.
So I used another account to continue CI/CD execution.

## 🎯 Key Decisions

- Used HTTP API (low cost, simple)
- Used Python 3.11 (fast, easy)
- Used Terraform modules (clean structure)
- Separated CI and CD pipelines
- Added security scanning (Trivy)

## 🔮 Future Improvements

- Add custom domain
- Add authentication
- Add CloudWatch monitoring
- Add multiple environments (dev/staging)

## 👨‍💻 Author

Somasekhar Jamalla