# Expense Architecture

![alt text](expense-infra-dev.drawio.svg)


---

# Terraform Infrastructure Deployment

##Overview

This repository contains Terraform configurations to provision and manage a scalable, secure, and highly available infrastructure on AWS. The setup includes networking components, compute resources, storage solutions, and security configurations, adhering to Infrastructure as Code (IaC) principles.

## Architecture Components

* **VPC**: Custom Virtual Private Cloud with public and private subnets across multiple Availability Zones.
* **EC2 Instances**: Provisioned in private subnets, managed via Auto Scaling Groups and Load Balancers.
* **RDS**: Managed PostgreSQL database instance with multi-AZ deployment for high availability.
* **S3 Buckets**: For static asset storage and Terraform remote state backend.
* **IAM Roles and Policies**: Fine-grained access control for resources and services.
* **Security Groups**: Strict inbound and outbound rules to secure network traffic.
* **Bastion Host**: Secure SSH access to private instances.

##  Repository Structure

```bash
terraform-infra-dev/
├── modules/                # Reusable Terraform modules
│   ├── vpc/                # VPC and networking
│   ├── ec2/                # EC2 instance configurations[ backend and frontend asg ]
│   ├── rds/                # RDS database setup
│   └── s3/                 # S3 bucket configurations
│   ├── bastion/            #bastion host configuration
│   ├── ec2/                # EC2 instance configurations
│   ├── ALB/                # ACM SSL setup
│   └── CDN/                # cloudfront confuguration
│   ├── ACM/                # EC2 instance configurations
├── environments/           # Environment-specific configurations
│   ├── dev/                # Development environment              
├── scripts/                # Helper scripts for automation
├── main.tf                 # Root module to orchestrate resources
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output values
├── terraform.tfvars        # Variable values for the environment
└── README.md               # Project documentation
```

## Getting Started

### Prerequisites

* [Terraform](https://www.terraform.io/downloads.html) v1.0 or higher
* AWS CLI configured with appropriate credentials
* Backend S3 bucket and DynamoDB table for remote state management

### Initialization

```bash
# Navigate to the desired environment
cd environments/dev

# Initialize Terraform
terraform init
```

### Planning

```bash
terraform plan -var-file=../../terraform.tfvars
```

### Deployment

```bash
terraform apply -var-file=../../terraform.tfvars
```

### Destruction

```bash
terraform destroy -var-file=../../terraform.tfvars
```

## 🔐 Remote State Management

Terraform state is managed remotely using AWS S3 and DynamoDB to ensure consistency and enable team collaboration.

* **S3 Bucket**: Stores the state files securely.
* **DynamoDB Table**: Manages state locking to prevent concurrent modifications.

## Modules

Each module is designed for reusability and encapsulates specific resources.

### VPC Module

* Creates a VPC with public and private subnets.
* Configures route tables and internet gateways.

### EC2 Module

* Launches EC2 instances within private subnets.
* Associates instances with security groups and IAM roles.

### RDS Module

* Provisions a PostgreSQL RDS instance with multi-AZ support.
* Sets up parameter groups and subnet groups.

### S3 Module

* Creates S3 buckets with versioning and encryption enabled.
* Configures bucket policies for access control.

## 🛡️ Security Considerations

* **IAM**: Implements the principle of least privilege.
* **Security Groups**: Restricts access to necessary ports and sources.
* **Encryption**: Enables encryption at rest and in transit for all services.
* **Secrets Management**: Integrate with AWS Secrets Manager for handling sensitive data.

## Monitoring and Logging

* **CloudWatch**: Collects logs and metrics for EC2 and RDS instances.
* **Alarms**: Sets up alarms for critical metrics to notify stakeholders.

## CI/CD Integration

Integrate this Terraform setup with CI/CD tools like Jenkins or GitHub Actions to automate the deployment process.

Example Jenkins workflow:

```
pipeline {
    agent any

    environment {
        AWS_CREDENTIALS = credentials('aws-credentials-id') // Jenkins stored AWS creds
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -var-file=terraform.tfvars'
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Approve to apply Terraform changes?', ok: 'Apply'
                sh 'terraform apply -auto-approve -var-file=terraform.tfvars'
            }
        }
    }

    post {
        failure {
            mail to: 'team@example.com',
                 subject: "Terraform Pipeline Failed: ${currentBuild.fullDisplayName}",
                 body: "Please check the Jenkins build logs."
        }
    }
}

```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

* [HashiCorp Terraform](https://www.terraform.io/)
* [AWS](https://aws.amazon.com/)
* [CloudPosse](https://github.com/cloudposse)
* [Terraform AWS Modules](https://github.com/terraform-aws-modules)

# Terraform: Taint

**Purpose:** 

Tainting a resource marks it for recreation during the next terraform apply operation. This is useful when you want to forcefully destroy and recreate a resource without changing its configuration.

Command: You can taint a resource using:

```bash
terraform taint <resource>
```

**Effect:** 

The resource will be destroyed and then recreated, even if there are no configuration changes. This can be useful when a resource becomes corrupted or you want to trigger a fresh start for it.

**Dependency Impact:** 

When you taint a resource that has dependencies (other resources rely on it), those dependent resources might not be destroyed and recreated unless their configuration explicitly changes as a result of the tainted resource being recreated. Terraform will maintain the dependency order but will only recreate the tainted resource unless other dependent resources are also affected indirectly.

# Terraform: Target

**Purpose:** 

The -target flag is used to apply or destroy only specific resources in a Terraform configuration, bypassing others.

Command: You can specify a target using:

```bash
terraform apply -target=<resource>
```
**Effect:** 

Terraform will only manage the targeted resource and ignore others during the plan and apply phases. This can be useful when you are debugging or deploying just a part of your infrastructure.

**Dependency Impact:** 

This is where it gets tricky. When you use -target on a resource that has dependencies, Terraform might not properly handle the dependent resources. If the target resource depends on something else or has resources depending on it, those dependencies may be missed, leading to a broken or incomplete state.

**NOTE:** Even you target a specific resource terraform will still evaluate the desired infra and actual infra.

**Best Practices:**
Use taint cautiously when you need to recreate a resource and want to ensure that all its dependencies are also properly handled by Terraform.
Avoid using -target in production for complex infrastructures with multiple dependencies. It can break dependency chains and lead to an inconsistent state. It's more suited for debugging or when you know for sure that focusing on a specific resource won't affect others.
If you have a complex dependency structure, it's usually better to let Terraform handle the entire graph of resources instead of trying to target specific ones.
