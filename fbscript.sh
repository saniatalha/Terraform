#!/bin/bash
sudo yum install httpd -y
sudo systemctl httpd start
sudo systemctl enable httpd 
echo "Welcome to my facebook page -TERRAFORM " > /var/www/html/index.html
