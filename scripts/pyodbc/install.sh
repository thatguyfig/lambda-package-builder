#!/bin/bash

# add microsoft repo
curl https://packages.microsoft.com/config/rhel/6/prod.repo > /etc/yum.repos.d/mssql-release.repo

# update yum
yum update -y

# download unixODBC source
cd /tmp
wget http://www.unixodbc.org/unixODBC-2.3.7.tar.gz

# unzip 
gunzip unixODBC-2.3.7.tar.gz
tar xvf unixODBC-2.3.7.tar
cd unixODBC-2.3.7

# configure the build to the lambda dir
./configure --sysconfdir=/var/task --disable-gui --disable-drivers --enable-iconv --with-iconv-char-enc=UTF8 --with-iconv-ucode-enc=UTF16LE --prefix=/home

# install it
make install

# move all created file to /var/task
mv /home/* /var/task

# install unixODBC-devel from RPM
rpm -i http://mirror.centos.org/centos/7/os/x86_64/Packages/unixODBC-2.3.1-14.el7.x86_64.rpm
rpm -i http://mirror.centos.org/centos/7/os/x86_64/Packages/unixODBC-devel-2.3.1-14.el7.x86_64.rpm

# next, install the msodbcsql drivers
ACCEPT_EULA=Y yum install -y msodbcsql gcc gcc-c++

# copy the driver locally also so we can use it for testing
cp -r /opt/microsoft/msodbcsql /var/task

# change into code dir
cd /var/task

# create files
cat <<EOF > odbcinst.ini
 
[ODBC Driver 13 for SQL Server]
 
Description=Microsoft ODBC Driver 13 for SQL Server
 
Driver=/var/task/msodbcsql/lib64/libmsodbcsql-13.1.so.9.2
 
UsageCount=1
 
EOF
 

cat <<EOF > odbc.ini
 
[ODBC Driver 13 for SQL Server]
 
Driver      = ODBC Driver 13 for SQL Server
 
Description = My ODBC Driver 13 for SQL Server
 
Trace       = No
 
EOF
