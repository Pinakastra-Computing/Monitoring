#!/bin/bash

# Make metabase user
sudo adduser --no-create-home --disabled-login --shell /bin/false --gecos "Metabase User" metabase

# Installing java JRE and JDK
sudo apt install openjdk-11-jdk openjdk-11-jre -y

# Download metabase.jar
VERSION=0.42.4
sudo wget https://downloads.metabase.com/v${VERSION}/metabase.jar

# Creating Directory and Moving Jar File
mkdir /opt/pinakastra/metabase
mv metabase.jar /opt/pinakastra/metabase/

# Change Ownership and log file setup
sudo chown -R metabase:metabase /opt/pinakastra/metabase
sudo touch /var/log/metabase.log
sudo chown metabase:metabase /var/log/metabase.log

# Create Service File
echo "[Unit]
Description=Metabase server
After=syslog.target
After=network.target

[Service]
WorkingDirectory=/opt/pinakastra/metabase/  
ExecStart=/usr/bin/java -jar /opt/pinakastra/metabase/metabase.jar
User=metabase
Type=simple
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=metabase
SuccessExitStatus=143
TimeoutStopSec=120
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/metabase.service

# Creating a Syslog configuration
echo "if $programname == 'metabase' then /var/log/metabase.log
& stop" | sudo tee -a /etc/rsyslog.d/metabase.conf

# Restarting the syslog service
sudo systemctl restart rsyslog.service

#Enable and test the Metabase service
sudo systemctl daemon-reload
sudo systemctl enable metabase
sudo systemctl start metabase