#! /bin/bash
# Install updates
sudo yum update -y

# Install Apache server
sudo yum install -y httpd

# Install MariaDB, PHP, and necessary tools
sudo yum install -y mariadb105-server php php-mysqlnd unzip

# Set database variables
DBName='shark_conservation_db'
DBUser='admin'
DBPassword='Sparten#48310'
DBRootPassword='rootpassword'
DBHost='shark-conservation-rds-mysql.cruoyiuk89xr.us-east-1.rds.amazonaws.com'

# Start Apache server and enable it on system startup
sudo systemctl start httpd
sudo systemctl enable httpd

# Start MariaDB service and enable it on system startup
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Set MariaDB root password
mysqladmin -u root password $DBRootPassword

# Download and install WordPress
wget http://wordpress.org/latest.tar.gz -P /var/www/html
cd /var/www/html
tar -zxvf latest.tar.gz
cp -rvf wordpress/* .
rm -R wordpress
rm latest.tar.gz

# Configure WordPress
cp ./wp-config-sample.php ./wp-config.php  # Rename the sample config file
sed -i "s/'database_name_here'/'$DBName'/g" wp-config.php
sed -i "s/'username_here'/'$DBUser'/g" wp-config.php
sed -i "s/'password_here'/'$DBPassword'/g" wp-config.php
sed -i "s/'localhost'/'$DBHost'/g" wp-config.php

# Grant permissions
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Create WordPress database
echo "CREATE DATABASE $DBName;" >> /tmp/db.setup
echo "CREATE USER '$DBUser'@'%' IDENTIFIED BY '$DBPassword';" >> /tmp/db.setup
echo "GRANT ALL ON $DBName.* TO '$DBUser'@'%';" >> /tmp/db.setup
echo "FLUSH PRIVILEGES;" >> /tmp/db.setup
mysql -h $DBHost -u root --password=$DBRootPassword < /tmp/db.setup
sudo rm /tmp/db.setup

# Sync files from S3 bucket
cd /var/www/html
sudo aws s3 sync s3://shark-conservation-blog/ .
