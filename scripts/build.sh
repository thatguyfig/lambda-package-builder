#!/bin/bash

echo '[*] Installing sytem dependencies...'

# update packages
yum update -y

# install curl, wget + zip
yum install -y curl wget zip


echo '[+] System dependency installation complete!'