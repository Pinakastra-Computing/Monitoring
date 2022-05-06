###################################################################
#Script Name	: HAProxy Setup                                                                                        
#Description	: HAProxy Setup Script                                                                       
#Args           :                                                                                    
#Author       	: Yashwant Bokadia (Pinakastra Computing)                                              
#Email         	: cloud@pinakastra.com                                           
###################################################################

#wget https://github.com/prometheus/haproxy_exporter/releases/download/v0.12.0/haproxy_exporter-0.12.0.linux-amd64.tar.gz
#tar -xzf haproxy_exporter-0.12.0.linux-amd64.tar.gz
#cd haproxy_exporter-*
#./haproxy_exporter --haproxy.scrape-uri 'http://localhost:80/;csv' &
#rm haproxy-*.tar.gz
#!/usr/bin/env bash

ARCH=amd64
VERSION=0.12.0
INSTALLDIR=/usr/local/bin
CONFIGDIR=/etc/prometheus

SRC_URL=https://github.com/prometheus/haproxy_exporter/releases/download/v${VERSION}/haproxy_exporter-${VERSION}.linux-${ARCH}.tar.gz

# Download and install the binary.
echo " - Download source from: ${SRC_URL}"
wget ${SRC_URL}
tar -zxf haproxy_exporter-${VERSION}.linux-${ARCH}.tar.gz
sudo mv haproxy_exporter-${VERSION}.linux-${ARCH}/haproxy_exporter ${INSTALLDIR}/haproxy_exporter-${VERSION}

# Create User/Group
#echo " - Adding user: haproxy_exporter"
#sudo useradd -M -s /bin/false haproxy_exporter

# Write config
echo " - Write config: ${CONFIGDIR}/haproxy_exporter.conf"
sudo mkdir -p ${CONFIGDIR}
sudo cp ./haproxy/haproxy_exporter.conf ${CONFIGDIR}/

# Write system service file.
echo " - Write systemd service file: /etc/systemd/system/haproxy_exporter.service"
echo "[Unit]
Description=HAProxy Prometheus Exporter
Wants=network-online.target
After=network-online.target
[Service]
EnvironmentFile=-${CONFIGDIR}/haproxy_exporter.conf
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/haproxy_exporter-${VERSION} \$HAPROXY_EXPORTER_OPTS
[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/haproxy_exporter.service > /dev/null

echo " - Done"

sudo systemctl daemon-reload
sudo systemctl enable haproxy_exporter
sudo systemctl start haproxy_exporter
