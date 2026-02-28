# ☁️ Cloud-Native Notes App – AWS Automation Project

A Cloud-Native Notes Application deployed entirely on **AWS using Terraform automation**.

This project focuses on Infrastructure as Code (IaC), AWS services integration, automated backups, and production-ready EC2 deployment — not just the Flask application.

---

## 📌 Project Overview

Cloud-Native Notes App is an automation-first AWS project designed to:

- Provision infrastructure using Terraform
- Deploy a Flask-based Notes application on EC2
- Use Amazon RDS (MySQL) for structured data storage
- Store daily database backups in Amazon S3
- Automate nightly backups using Cron jobs
- Secure infrastructure using IAM Roles
- Follow Infrastructure as Code best practices

---

## 🏗️ Architecture

```
User → EC2 (Flask App)
            ↓
        Amazon RDS (MySQL)
            ↓
     Nightly Backup Script (Cron)
            ↓
        Amazon S3 (Backup Storage)
```

Infrastructure is provisioned fully using:

Terraform → AWS Provider → EC2 + RDS + S3 + IAM

---

## 🚀 Core Features

### 📝 Notes Application (Flask)

- Create and delete notes
- Search by content or tag
- Categorize notes by:
  - Subjects
  - Topics
  - Custom tags
- Notes sorted by latest entry
- Timestamp tracking

---

### 🗄 Database Layer (Amazon RDS – MySQL)

- Structured storage of notes
- Auto-increment primary key
- Timestamp-based ordering
- Secure credential handling using environment variables

Table Structure:

```
notes
- id (INT, Primary Key, Auto Increment)
- content (TEXT)
- tag (VARCHAR)
- created_at (TIMESTAMP)
```

---

### ☁️ AWS Infrastructure (Terraform)

Provisioned Resources:

- EC2 Instance (Amazon Linux 2)
- RDS MySQL Instance
- S3 Bucket (Daily Backups)
- IAM Role & Policy (S3 Access)
- Security Groups (HTTP + SSH)
- Instance Profile

All infrastructure is defined using Terraform modules.

---

## 🔐 Security & Access

- IAM Role attached to EC2 for S3 access
- No hardcoded AWS credentials in application
- Environment variables used for DB configuration
- Security Groups restrict access to required ports
- Private S3 bucket for backup storage

---

## 🔄 Automated Nightly Backup

A Cron job runs daily at 2:00 AM:

```
0 2 * * * /home/ec2-user/db_backups/backup_rds.sh >> /home/ec2-user/db_backups/backup.log 2>&1
```

Backup Process:

1. Dump RDS MySQL database
2. Store backup locally
3. Upload backup file to S3 bucket
4. Log execution output

This ensures automated disaster recovery support.

---

## 🛠 Tech Stack

### Application Layer
- Flask (Python)
- PyMySQL
- Jinja2 Templates

### Cloud & Infrastructure
- AWS EC2
- AWS RDS (MySQL 8.0)
- AWS S3
- AWS IAM
- Amazon Linux 2
- Cron Scheduler

### Infrastructure as Code
- Terraform
- AWS Provider

---

## 📦 Project Structure

```
notes-app/
│
├── app/
│   ├── app.py
│   ├── templates/
│   ├── static/
│   └── requirements.txt
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── user_data.sh
│
├── .gitignore
└── README.md
```

---

## ⚙️ Terraform Deployment

### 1️⃣ Initialize Terraform

```bash
terraform init
```

### 2️⃣ Plan Infrastructure

```bash
terraform plan
```

### 3️⃣ Apply Infrastructure

```bash
terraform apply
```

After successful deployment, Terraform outputs:

- EC2 Public IP
- S3 Bucket Name

Access Application:

```
http://<EC2_PUBLIC_IP>
```

---

## 🔑 IAM Role Configuration

EC2 is assigned an IAM Role with permissions:

- s3:PutObject
- s3:ListBucket

This allows secure backup upload to S3 without storing access keys on the instance.

---

## 🗃️ S3 Backup Storage

- Randomized bucket name
- Private access
- Stores daily database dumps
- Organized for recovery

---

## 🧪 Database Verification

After deployment:

Connect to RDS:

```sql
USE notesdb;
SHOW TABLES;
DESCRIBE notes;
```

Confirms:

- Structured table creation
- Timestamp-based sorting
- Auto-increment primary key

---

## 🎯 Cloud-Native Highlights

✔ Infrastructure as Code (Terraform)  
✔ Fully automated AWS provisioning  
✔ EC2 + RDS + S3 integration  
✔ IAM-based secure access  
✔ Nightly automated database backups  
✔ Environment-based configuration  
✔ Production-ready architecture  

---

## 📈 Future Improvements

- Move EC2 to Auto Scaling Group
- Add Application Load Balancer
- Private RDS subnet configuration
- Enable S3 lifecycle policies
- CI/CD deployment pipeline
- Docker containerization
- CloudWatch monitoring & alerts

---

## 📄 License

MIT License — Free to use for learning and portfolio projects.

---

## 👨‍💻 Author

**Kolli Jayanth Eswar**

Cloud & DevOps Engineer  
AWS | Terraform | Infrastructure Automation
