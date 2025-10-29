terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security group
resource "aws_security_group" "notes_sg" {
  name        = "notes-sg"
  description = "Allow HTTP and SSH"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create S3 bucket for backups
resource "aws_s3_bucket" "notes_backup" {
  bucket = "notes-backup-${random_id.bucket_id.hex}"
  acl    = "private"

  tags = {
    Name = "NotesBackupBucket"
  }
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

# IAM role for EC2 to access S3
resource "aws_iam_role" "ec2_role" {
  name = "notesapp-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = { Service = "ec2.amazonaws.com" },
      Effect = "Allow",
    }]
  })
}

resource "aws_iam_policy" "s3_policy" {
  name        = "notesapp-s3-policy"
  description = "Allow EC2 to access S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["s3:PutObject", "s3:ListBucket"],
      Effect   = "Allow",
      Resource = [
        aws_s3_bucket.notes_backup.arn,
        "${aws_s3_bucket.notes_backup.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "notesapp-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 instance
resource "aws_instance" "notes_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.notes_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  user_data              = file("${path.module}/user_data.sh")

  tags = {
    Name = "NotesApp"
  }
}

output "public_ip" {
  value = aws_instance.notes_instance.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.notes_backup.bucket
}

# -----------------------------
# RDS MySQL Instance
# -----------------------------

resource "aws_db_instance" "notes_rds" {
  identifier              = "notesapp-db"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "MySecurePassword123!"   # use a strong password!
  db_name                 = "notesdb"
  publicly_accessible     = true
  skip_final_snapshot     = true

  vpc_security_group_ids  = [aws_security_group.notes_sg.id]
}