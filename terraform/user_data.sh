#!/bin/bash
yum update -y
yum install -y python3 git awscli

# Clone your GitHub app
cd /home/ec2-user
git clone https://github.com/KOLLIJAYANTHESWAR/notes-app.git
cd notes-app/app

# Install dependencies
pip3 install -r requirements.txt

# Set environment variable for backup
BUCKET_NAME=$(aws s3 ls | grep notes-backup | awk '{print $3}')
echo "S3 Bucket for backup: $BUCKET_NAME" > /home/ec2-user/backup.log

# Create backup script
cat <<'EOF' > /home/ec2-user/backup_notes.sh
#!/bin/bash
cd /home/ec2-user/notes-app/app
timestamp=$(date +%Y-%m-%d-%H-%M-%S)
aws s3 cp notes.db s3://$BUCKET_NAME/backup-\$timestamp.db
EOF

chmod +x /home/ec2-user/backup_notes.sh

# Schedule backup every 5 minutes
echo "*/5 * * * * ec2-user /home/ec2-user/backup_notes.sh" >> /etc/crontab

# Start the app
nohup python3 app.py > app.log 2>&1 &
