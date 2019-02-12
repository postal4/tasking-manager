#!/bin/bash
#
# Script to install the Tasking Manager on Ubuntu 16.04
#

# Ensure being run on the supported operating system
distribution=$(lsb_release -si)
version=$(lsb_release -sc)

if [ "$distribution" != "Ubuntu" ] || [ "$version" != "xenial" ]; then
  echo -e "ERROR: Your operating system is not supported by this installation script"
  exit
fi

# Make sure the system is up-to-date
sudo apt-get update &&
sudo apt-get -y upgrade &&

# Install general tools
sudo apt-get -y install curl git &&

# Install Python
sudo add-apt-repository ppa:jonathonf/python-3.6 &&
sudo apt-get update &&
sudo apt-get -y install python3.6 &&
sudo apt-get -y install python3.6-dev &&
sudo apt-get -y install python3.6-venv &&

# Install Node
curl -sL https://deb.nodesource.com/setup_6.x > install-node6.sh &&
sudo chmod +x install-node6.sh &&
sudo ./install-node6.sh &&
sudo apt-get -y install nodejs &&
sudo npm install gulp -g &&
npm i browser-sync --save &&

# Install database
sudo apt-get -y install postgresql-9.5 &&
sudo apt-get -y install libpq-dev &&
sudo apt-get -y install postgresql-server-dev-9.5 &&
wget http://postgis.net/stuff/postgis-2.2.4.tar.gz &&
tar -xvzf postgis-2.2.4.tar.gz &&
sudo apt-get -y install libxml2 &&
sudo apt-get -y install libxml2-dev &&
sudo apt-get -y install libgeos-3.5.0 &&
sudo apt-get -y install libgeos-dev &&
sudo apt-get -y install libproj9 &&
sudo apt-get -y install libproj-dev &&
sudo apt-get -y install libgdal1-dev &&
sudo apt-get -y install libjson-c-dev &&
cd postgis-2.2.4 &&
./configure &&
make &&
sudo make install &&
cd .. &&

# Install the Tasking Manager
git clone --recursive https://github.com/hotosm/tasking-manager.git &&
cd tasking-manager/ &&
python3.6 -m venv ./venv &&
. ./venv/bin/activate &&
pip install --upgrade pip &&
pip install -r requirements.txt &&

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p &&

# Set up database
sudo -u postgres psql -c "CREATE USER hottm WITH PASSWORD 'hottm';" &&
sudo -u postgres createdb -T template0 tasking-manager -E UTF8 -O hottm &&
sudo -u postgres psql -d tasking-manager -c "CREATE EXTENSION postgis;" &&
export TM_DB="postgresql://hottm:hottm@localhost/tasking-manager" &&
export TM_CONSUMER_KEY="VLm4AmuigZODSZQSEEdarv8LhFi4NFodc9JbvvEl" &&
export TM_CONSUMER_SECRET="hkS6CwbTJjpwPeIuVJemj4Y5H2WoXYYpiSUBVlhO" &&
export TM_ENV="Dev" &&
export TM_SECRET="45dfHJJ456dRh378gGFergeqrgtDFGerterRte" &&
./venv/bin/python3.6 manage.py db upgrade &&

# Set up the Tasking Manager's interface
cd client/ &&
npm install &&
gulp build &&
cd ../ &&

# Start dev server
venv/bin/python manage.py runserver -d