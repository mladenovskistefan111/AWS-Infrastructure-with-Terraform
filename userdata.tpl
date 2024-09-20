#!/bin/bash
sudo yum update -y
sudo yum install -y httpd git unzip php php-mysqlnd php-pdo php-gd php-mbstring

sudo systemctl start httpd
sudo systemctl enable httpd

sudo mkdir -p /var/www/html/health
echo "<html><body>OK</body></html>" | sudo tee /var/www/html/health/index.html

wget https://wordpress.org/latest.zip -O /tmp/wordpress.zip
sudo unzip /tmp/wordpress.zip -d /var/www/html/
sudo mv /var/www/html/wordpress/* /var/www/html/
sudo rmdir /var/www/html/wordpress
sudo chown -R apache:apache /var/www/html

sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/${dbname}/" /var/www/html/wp-config.php
sudo sed -i "s/username_here/${dbuser}/" /var/www/html/wp-config.php
sudo sed -i "s/password_here/${dbpassword}/" /var/www/html/wp-config.php
sudo sed -i "s/localhost/${db_endpoint}/" /var/www/html/wp-config.php

sudo systemctl restart httpd

sudo yum install -y amazon-cloudwatch-agent

sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json <<EOF
{
  "metrics": {
    "namespace": "Disk/Memory",
    "metrics_collected": {
      "disk": {
        "measurement": [
          "disk_used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl start amazon-cloudwatch-agent
sudo systemctl start amazon-ssm-agent
