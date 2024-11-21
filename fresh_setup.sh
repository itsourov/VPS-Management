#!/bin/bash

# Update and upgrade packages
echo "Updating package lists..."
sudo apt update -y && sudo apt upgrade -y

# Install essential packages
echo "Installing Nginx..."
sudo apt install nginx -y

# Configure UFW for Nginx and SSH
echo "Configuring UFW..."
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx HTTPS'
sudo ufw allow 'OpenSSH'

# Add a new user and grant sudo privileges
NEW_USER="sourov"
echo "Creating new user $NEW_USER..."
sudo adduser --gecos "" $NEW_USER
sudo usermod -aG sudo $NEW_USER

# Setup SSH keys for the new user
echo "Setting up SSH keys for $NEW_USER..."
sudo mkdir -p /home/$NEW_USER/.ssh
sudo cp /root/.ssh/authorized_keys /home/$NEW_USER/.ssh/
sudo chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
sudo chmod 700 /home/$NEW_USER/.ssh
sudo chmod 600 /home/$NEW_USER/.ssh/authorized_keys

# Install PHP 8.3 and extensions
echo "Installing PHP 8.3 and extensions..."
sudo apt install -y php8.3-fpm php8.3-mysql php8.3-cli php8.3-common php8.3-mbstring php8.3-xml php8.3-zip php8.3-redis

# Install MySQL Server
echo "Installing MySQL..."
sudo apt install -y mysql-server

# Generate a random MySQL root password
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 16)
echo "Generated MySQL root password: $MYSQL_ROOT_PASSWORD"
echo $MYSQL_ROOT_PASSWORD > /home/$NEW_USER/mysql_root_password.txt
sudo chown $NEW_USER:$NEW_USER /home/$NEW_USER/mysql_root_password.txt
sudo chmod 600 /home/$NEW_USER/mysql_root_password.txt

# Configure MySQL root password
echo "Configuring MySQL root password..."
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"

# Start MySQL and enable it on boot
echo "Starting MySQL..."
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure MySQL installation (Optional steps can be automated or skipped as needed)
echo "Securing MySQL installation..."
sudo mysql_secure_installation <<EOF

y
$MYSQL_ROOT_PASSWORD
$MYSQL_ROOT_PASSWORD
y
y
y
y
EOF

# Install Redis Server
echo "Installing Redis server..."
sudo apt install -y redis-server

# Final message
echo "VPS setup complete! MySQL root password saved at /home/$NEW_USER/mysql_root_password.txt."
