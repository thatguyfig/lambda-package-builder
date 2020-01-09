#!/bin/bash 

# add the ms repo
curl https://packages.microsoft.com/config/rhel/7/prod.repo | tee /etc/yum.repos.d/microsoft.repo

# install powershell
yum install -y powershell