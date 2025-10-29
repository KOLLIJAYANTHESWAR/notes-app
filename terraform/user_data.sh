#!/bin/bash
yum update -y
yum install -y python3 git

# Clone your app repo
cd /home/ec2-user
git clone https://github.com/YOUR_GITHUB_USERNAME/notes-app.git
cd notes-app/app

# Install dependencies
pip3 install -r requirements.txt

# Start the app in background
nohup python3 app.py > app.log 2>&1 &
