#!/bin/bash

# Update the system and install Apache
apt update -y
apt install -y httpd

# Start and enable Apache to run on boot
systemctl start httpd
systemctl enable httpd

# Fetch the latest token for accessing EC2 instance metadata
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Fetch the instance ID
INSTANCEID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id -H "X-aws-ec2-metadata-token: $TOKEN")

# Create or overwrite index.html with the instance ID information
echo "<center><h1>This instance has the ID: $INSTANCEID </h1></center>" > /var/www/html/index.html

# Ensure httpd can read the index.html file and its directory
chown apache:apache /var/www/html/index.html
chmod 755 /var/www/html
chmod 644 /var/www/html/index.html

# Restart Apache to apply changes
systemctl restart httpd