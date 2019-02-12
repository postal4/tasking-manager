#!/bin/bash
#
# Script to install the Tasking Manager on CentOS 7
#

## Install general tools
sudo yum install -y epel-release &&
sudo yum update -y &&
sudo yum install -y vim git wget bzip2 nano htop &&

## Install required database 
sudo rpm -ivh http://yum.postgresql.org/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-2.noarch.rpm &&
sudo yum install postgresql95 postgresql95-server postgresql95-libs postgresql95-contrib postgresql95-devel &&
sudo /usr/pgsql-9.5/bin/postgresql95-setup initdb &&
sudo service postgresql-9.5 start &&
sudo chkconfig postgresql-9.5 on &&
sudo yum install postgis2_95  &&

# Create Postgresql Users
sudo -u postgres createuser -s centos &&
sudo -u postgres createuser -s apache &&

# Install dependencies for Node
sudo yum install gcc gcc-c++ &&
sudo yum groupinstall "Development Tools" &&

# Download and install node
curl https://raw.githubusercontent.com/creationix/nvm/v0.25.0/install.sh | bash
# ---Exit and Re-enter server
nvm install 8.4 &&
nvm alias default 8.4 &&

# Download and install Python 3.6
sudo yum install https://centos7.iuscommunity.org/ius-release.rpm &&
sudo yum install python36u python36u-pip python36u-devel &&

# Install Tasking Manager
cd /var/www/html &&
sudo git clone https://github.com/hotosm/tasking-manager &&
sudo chown -R centos:centos tasking-manager/ &&

# Install Node Deps
cd tasking-manager/ &&
cd client/ &&
npm install &&
npm install gulp -g &&
gulp build &&

# Create Python Virtual Env
cd ../ &&
python3.6 -m venv ./venv &&
. ./venv/bin/activate &&
pip3 install -r requirements.txt &&

# Create database
Create Postgresql Database &&
sudo -u postgres psql &&
CREATE USER "hottm" PASSWORD 'hottm'; &&
CREATE DATABASE "tasking-manager" OWNER "hottm"; &&
\c "tasking-manager"; &&
CREATE EXTENSION postgis; &&
Create Server Env Variables &&

# Set environment variables
export PATH=$PATH:$HOME/.local/bin:$HOME/bin
export TM_DB=postgresql://hottm:hottm@localhost/tasking-manager
export TM_SECRET=secret-key-here
export TM_CONSUMER_KEY=oauth-consumer-key-goes-here
export TM_CONSUMER_SECRET=oauth-consumer-secret-key-goes-here
export TM_SMTP_PASSWORD=smtp-server-password-here
export TASKING_MANAGER_ENV=Dev

# Initialize DB
python3.6 manage.py db upgrade &&

# Run Dev Server
python3.6 manage.py runserver -d