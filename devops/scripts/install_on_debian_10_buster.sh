#!/bin/bash
#
# Script to install the Tasking Manager on Debian 10 Buster
#

# Ensure being run on the supported operating system
distribution=$(lsb_release -si)
version=$(lsb_release -sc)

if [ "$distribution" != "Debian" ] || [ "$version" != "buster" ]; then
  echo -e "ERROR: Your operating system is not supported by this installation script"
  exit
fi

# Make sure the system is up-to-date
sudo apt update && sudo apt upgrade &&

## Install general tools
sudo apt install git curl software-properties-common build-essential &&

## Install required dependencies
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash - &&
sudo apt install python3 python3-venv postgresql postgis nodejs postgresql-server-dev-all &&
sudo npm install gulp -g &&

## Obtain the tasking manager
git clone --recursive https://github.com/hotosm/tasking-manager.git &&

## Prepare the tasking manager
cd tasking-manager/ &&
python3.6 -m venv ./venv &&
. ./venv/bin/activate &&
pip install --upgrade pip &&
pip install -r requirements.txt &&

# Set up data base
sudo -u postgres psql -c "CREATE USER hottm WITH PASSWORD 'hottm';" &&
sudo -u postgres createdb -T template0 tasking-manager -E UTF8 -O hottm &&
sudo -u postgres psql -d tasking-manager -c "CREATE EXTENSION postgis;" &&

# Configure the tasking manager
export TM_DB="postgresql://hottm:hottm@localhost/tasking-manager" &&
export TM_CONSUMER_KEY="VLm4AmuigZODSZQSEEdarv8LhFi4NFodc9JbvvEl" &&
export TM_CONSUMER_SECRET="hkS6CwbTJjpwPeIuVJemj4Y5H2WoXYYpiSUBVlhO" &&
export TM_ENV="Dev" &&
export TM_SECRET="45dfHJJ456dRh378gGFergeqrgtDFGerterRte" &&
./venv/bin/python3 manage.py db upgrade &&

# Assamble the tasking manager interface
cd client/ &&
npm install &&
gulp build &&
cd ../ &&

# Start the tasking manager
venv/bin/python manage.py runserver -d