FROM lambci/lambda:build-python3.7

# add the required scripts
ADD ./scripts /scripts

# add python code
ADD ./code /var/task

# provide execute permission, to required scripts
RUN chmod +x /scripts/build.sh
RUN chmod +x /scripts/deploy.sh
RUN chmod +x /scripts/zip.sh

# (1) install required software
RUN /scripts/build.sh

# (1a) (optionally) install custom software depdencies
    # install pyodbc
    RUN chmod +x /scripts/pyodbc/install.sh
    RUN /scripts/pyodbc/install.sh
    
# (2) install other python packages required for your code
RUN /scripts/deploy.sh

# (3) finally, zip the code to /lambda-package.zip
RUN /scripts/zip.sh