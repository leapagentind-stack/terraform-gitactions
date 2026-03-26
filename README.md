# Internal Utility Service Deployment

## Overview

This project demonstrates the deployment of a small internal utility service to AWS using Terraform for infrastructure provisioning and GitHub Actions for CI/CD automation. The service is a simple AWS Lambda function exposed via API Gateway that returns a "Hello from AWS" message.

## Architecture

```mermaid
graph TB
    subgraph "GitHub"
        PR[Pull Request] --> CI[CI Pipeline]
        Merge[Merge to Main] --> CD[CD Pipeline]
    end
    
    subgraph "GitHub Actions"
        CI --> |Run Checks| Lint[Terraform Lint]
        CI --> |Run Checks| TFLint[TFLint]
        CI --> |Run Checks| Flake8[Python Flake8]
        CI --> |Run Checks| Trivy[Trivy Security Scan]
        
        CD --> |Deploy| TFInit[Terraform Init]
        CD --> |Deploy| TFPlan[Terraform Plan]
        CD --> |Deploy| TFApply[Terraform Apply]
    end
    
    subgraph "AWS Cloud - us-east-1"
        subgraph "API Gateway"
            API[HTTP API Gateway<br/>internal-prod-api]
            Stage[$default Stage<br/>Auto Deploy]
            Route[GET /hello Route]
        end
        
        subgraph "Lambda"
            Lambda[Lambda Function<br/>internal-prod-lambda<br/>Python 3.11]
            Handler[lambda_function.lambda_handler]
        end
        
        subgraph "IAM"
            Role[IAM Role<br/>internal-prod-lambda-role]
            Policy[AWSLambdaBasicExecutionRole]
        end
        
        subgraph "Terraform State"
            S3[S3 Bucket<br/>tfstate-somu]
        end
    end
    
    User([User/Client]) -->|HTTP GET /hello| API
    API --> Route
    Route -->|AWS_PROXY Integration| Lambda
    Lambda -->|AssumeRole| Role
    Role --> Policy
    TFApply -->|Manage| API
    TFApply -->|Manage| Lambda
    TFApply -->|Manage| Role
    TFApply -->|Store State| S3
    
    style API fill:#FF9900,stroke:#232F3E,color:#232F3E
    style Lambda fill:#FF9900,stroke:#232F3E,color:#232F3E
    style Role fill:#3B48CC,stroke:#232F3E,color:#FFFFFF
    style Policy fill:#3B48CC,stroke:#232F3E,color:#FFFFFF
    style User fill:#2E7D32,stroke:#1B5E20,color:#FFFFFF
    style CI fill:#2196F3,stroke:#1565C0,color:#FFFFFF
    style CD fill:#2196F3,stroke:#1565C0,color:#FFFFFF
```

## Project Structure

```
terraform-gitactions/
├── .github/
│   └── workflows/
│       ├── ci.yml          # CI pipeline for pull requests
│       └── deploy.yml      # CD pipeline for production deployment
├── app/
│   └── lambda_function.py  # Lambda function code
├── modules/
│   ├── api_gateway/        # API Gateway Terraform module
│   ├── iam/                # IAM roles and policies module
│   └── lambda/             # Lambda function module
├── scripts/
│   └── package.sh          # Lambda packaging script
├── terraform/
│   └── envs/
│       └── prod/           # Production environment configuration
└── README.md
```

## Application

The application is a simple AWS Lambda function written in Python 3.11:

```python
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "Hello from AWS - this is somasekhar jamalla"
    }
```

## Infrastructure

### Components

1. **AWS Lambda**: Serverless function running Python 3.11
2. **API Gateway (HTTP API)**: Exposes the Lambda function via HTTP endpoint
3. **IAM Role**: Provides execution permissions for the Lambda function
4. **S3 Backend**: Stores Terraform state remotely

### API Endpoint

- **URL**: `https://<api-id>.execute-api.us-east-1.amazonaws.com/hello`
- **Method**: GET
- **Response**: "Hello from AWS - this is somasekhar jamalla"

## CI/CD Pipeline

### CI Pipeline (ci.yml)

Triggers on pull requests and runs:

1. **Terraform Init**: Initializes Terraform without backend
2. **Terraform Format Check**: Validates code formatting
3. **Terraform Validate**: Validates Terraform configuration
4. **TFLint**: Lints Terraform code for best practices
5. **Flake8**: Lints Python code
6. **Trivy Security Scan**: Scans for security vulnerabilities

### CD Pipeline (deploy.yml)

Triggers on push to main branch and:

1. **Packages Lambda**: Creates deployment package
2. **Terraform Init**: Initializes with S3 backend
3. **Terraform Plan**: Shows infrastructure changes
4. **Terraform Apply**: Applies changes to AWS

## Challenges Faced and Resolutions

### Challenge 1: Invalid Workflow Dependency in deploy.yml

**Problem**: The `deploy.yml` workflow had an invalid dependency:
```yaml
deploy-prod:
  name: Deploy to PROD
  needs: deploy-dev  # This job doesn't exist!
```

**Error**: 
```
The workflow must contain at least one job with no dependencies.
```

**Resolution**: Removed the invalid `needs: deploy-dev` line since there was no `deploy-dev` job defined. The workflow now has a valid starting point.

### Challenge 2: CI Workflow File Issues

**Problem**: Multiple issues with `ci.yml`:

1. **Filename Issue**: The file had a trailing space (`ci.yml ` instead of `ci.yml`), causing GitHub Actions to not recognize it properly.

2. **Missing Terraform Installation**: The workflow tried to run Terraform commands without installing Terraform first:
   ```
   terraform: command not found
   ```

3. **Invalid Trivy Action Version**: Used non-existent version `0.20.0`:
   ```
   Unable to resolve action `aquasecurity/trivy-action@0.20.0`
   ```

4. **Inconsistent Directory Paths**: Terraform format check ran from repo root while other commands ran from `terraform/envs/prod`.

**Resolutions**:

1. **Fixed Filename**: Renamed file to remove trailing space
   ```bash
   mv ".github/workflows/ci.yml " ".github/workflows/ci.yml"
   ```

2. **Added Terraform Installation**:
   ```yaml
   - name: Setup Terraform
     uses: hashicorp/setup-terraform@v2
     with:
       terraform_version: 1.5.0
   ```

3. **Updated Trivy Version**: Changed to valid version `0.30.0`
   ```yaml
   uses: aquasecurity/trivy-action@0.30.0
   ```

4. **Fixed Directory Paths**: Made all Terraform commands run from `terraform/envs/prod`:
   ```yaml
   - name: Terraform Format Check
     run: |
       cd terraform/envs/prod
       terraform fmt -check -recursive
   ```

### Challenge 3: Python Linting Error

**Problem**: Flake8 reported missing newline at end of file:
```
app/lambda_function.py:5:6: W292 no newline at end of file
```

**Resolution**: Added newline at the end of `lambda_function.py` file.

## Setup Instructions

### Prerequisites

- AWS Account with appropriate permissions
- GitHub account
- Terraform installed locally (for manual testing)

### Deployment Steps

1. **Fork/Clone Repository**
   ```bash
   git clone https://github.com/jamallasomasekhar/terraform-gitactions.git
   ```

2. **Configure AWS Credentials**
   
   Add the following secrets to your GitHub repository:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

3. **Create Pull Request**
   
   Push changes to a feature branch and create a PR. The CI pipeline will run automatically.

4. **Merge to Main**
   
   Once CI passes, merge to main. The CD pipeline will deploy to AWS.

5. **Access Application**
   
   After deployment, access the API at:
   ```
   https://<api-id>.execute-api.us-east-1.amazonaws.com/hello
   ```

## Video Demo

[Video Demo URL - To be added]

## Notes

### GitHub Actions Collaboration

**Important**: The original GitHub account (`jamallasomasekhar`) reached the GitHub Actions usage limit. To continue development and demonstration, I collaborated using another GitHub account. The repository is hosted at:

- **Repository**: `git@github.com:jamallasomasekhar/terraform-gitactions.git`
- **Collaboration**: Used secondary account for CI/CD pipeline execution

This is a common scenario in real-world projects where teams may need to manage multiple accounts or collaborate across organizations.

## Key Decisions

1. **HTTP API vs REST API**: Chose HTTP API (API Gateway v2) for lower cost and simpler setup for this internal utility.

2. **Lambda Runtime**: Selected Python 3.11 for simplicity and fast cold starts.

3. **Terraform Modules**: Organized infrastructure into reusable modules (IAM, Lambda, API Gateway) for better maintainability.

4. **CI/CD Separation**: Separated CI (pull request checks) and CD (deployment) pipelines for better control.

5. **Security Scanning**: Included Trivy for vulnerability scanning to demonstrate security best practices.

6. **State Management**: Used S3 backend for Terraform state to enable team collaboration.

## Future Enhancements

- Add custom domain name for API Gateway
- Implement API authentication
- Add CloudWatch alarms and monitoring
- Set up multiple environments (dev, staging, prod)
- Add integration tests

## Author

Somasekhar Jamalla

## License

This project is for educational purposes as part of an assignment.