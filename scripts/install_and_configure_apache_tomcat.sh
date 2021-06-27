#!/bin/bash

yum -y update
yum -y install wget
amazon-linux-extras install java-openjdk11

export VER="9.0.39"
groupadd --system tomcat
useradd -d /usr/share/tomcat -r -s /bin/false -g tomcat tomcat

wget https://archive.apache.org/dist/tomcat/tomcat-9/v${VER}/bin/apache-tomcat-${VER}.tar.gz
tar xvf apache-tomcat-${VER}.tar.gz -C /usr/share/
ln -s /usr/share/apache-tomcat-$VER/ /usr/share/tomcat

chown -R tomcat:tomcat /usr/share/tomcat
chown -R tomcat:tomcat /usr/share/apache-tomcat-$VER/

tee /etc/systemd/system/tomcat.service<<EOF
[Unit]
Description=Tomcat Server
After=syslog.target network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment='JAVA_OPTS=-Djava.awt.headless=true'
Environment=CATALINA_HOME=/usr/share/tomcat
Environment=CATALINA_BASE=/usr/share/tomcat
Environment=CATALINA_PID=/usr/share/tomcat/temp/tomcat.pid
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M'
ExecStart=/usr/share/tomcat/bin/catalina.sh start
ExecStop=/usr/share/tomcat/bin/catalina.sh stop

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

yum -y install httpd
systemctl restart httpd
systemctl enable httpd
