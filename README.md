# lambda-docker-builder

A docker based lambda package builder, to create deployment packages for uploading to S3.

## The Why

Producing Lambda deployment packages on Windows machines is a difficult task. As the machine executing the Python scripts is Linux based, we must use the correct Line endings to the match the system. Windows use - CRLF, Linux use - LF

If not, Lambda will fail to execute the script as it cannot determine where the end of a line is. To do this correctly, we can set the line endings of every file to be UNIX, but it is much easier to build the package in Linux where line endings will already be correct.

Also, there are times when Linux must compile the from source the necessary software and can only be done on a Linux machine due to the expected libraries and build tools that may not be compatible with Windows. It's this OS hell which Docker can help out with. 

This is due to the fact the code will be deployed to `/var/task` and therefore any software bundled with the package must be configured to be run from that directory and not the usual path.

Additionally, the only writeable location available in lambda during execution is `/tmp`. Any file creations must be made there in order to have to permissions to complete the task.

## Usage

### Configuring the Container

1. Install the following:
   1. Docker for Desktop and make sure you can run containers as normal. <https://docs.docker.com/docker-for-windows/>
   2. Git command line

2. Clone this repository:

    ```bash
    cd C:\
    mkdir git
    cd git
    git clone https://git.mdevlab.com/Tom.Thornton/lambda-docker-builder.git
    ```

3. Change into the directory:

    ```bash
    cd lambda-docker-builder
    ```

### Install your Code

Copy your python script / modules to the `code\` directory, make sure any of your line-endings are UNIX formatted (LF).

For the builder to recognise the required packages for your code, you must include the following:

- `requirements.txt`
  - This is needed for the build process to install the correct dependencies


#### Install Code from Git

You can use the util script found in `utils\` called `InstallGitRepo.ps1`, this will pull code from Git and set it up correctly inside the `code\` folder. Any required Python packages must exist in the `requirements.txt` file otherwise when you run the code in Lambda you will find modules are missing.

Configure the git repo URL in the PowerShell script like so:

```powershell
$gitRepoURL = "https://github.com/username/project.git"
```

Execute the repo install using the following command:

```cmd
powershell -file .\utils\InstallGitRepo.ps1
```

### Build the Container

In order to create the deployment package you must use Docker to build the image. In order to do this run the following command whilst in the same directory as the `Dockerfile`:

```cmd
docker build . -t name-of-image
```

The process will kick off and Docker will read each line of the `Dockerfile` performing each of the steps. If you need additional automation, please see the steps below.

### Running the Container Interactively

In order to interact with the container we just built and check it's functionality, we can run the container with the below command (using the same image name as used above):

```cmd
docker run -it --rm --entrypoint bash name-of-image
```

### Exporting the Deployment ZIP File

Once the build has been completed and you have a container running interactively, open a new terminal and run the following script:

```cmd
powershell -file .\utils\ExtractZipFile.ps1
```

### That's it! Upload to S3

Now you've exported the package, upload it to S3 and point you Lambda function to the code. Don't forget to set the correct Python version and the handler name!

You'll be asked to provide the name of the container with your deployment package as provided in the output

## Container Workflow

The work behind the building of the lambda package deployment zip is done during the build of the container, and at the end a finished package is created. 

Please ensure to check the logs to ensure the build is succesful, if any error is encountered the container will fail to build.

### Build

We first prepare a container with the following software, through the use of the `scripts/build.sh` file:

- yum update (to update any packages)
- install wget, curl, zip for later usage

### Optional Software Install

Sometimes in the case of certain python packages, dependent software is required to build the package from wheel file. This sometimes means install development packages to help with building from C header files.

See information further down if you wish to add your own install scripts.

### Deploy

Next, we call our build process through the use of the `scripts/deploy.sh` file which:

- Installs all pip modules as defined in the `code/requirements.txt` file, which must:
  - Use the standard format for a `requirements.txt` file

### Zip

Finally, once all the Python packages have been installed, a zip file is created at:

- `/lambda-package.zip`

## Useful Commands

### Build and Launch 

This is a combination of the above to first build, and then launch into the container:

`docker build . -t lambda-builder && docker run -it --rm --entrypoint bash lambda-builder`

### Build and Extract

This is an additional command to run the interactive extraction command script straight after the build:

`docker build . -t lambda-builder && docker run -it --rm --entrypoint bash lambda-builder`

In a separate terminal run the below whilst the container is running to extract the zip file.

`powershell -file .\utils\ExtractZipFile.ps1`


## Installing other Software Dependencies

If you need to first install other dependencies, the likes of unixODBC or PowerShell as an example, please see the directories inside `scripts/`, there you will find some example scripts to perform further install steps.

Add your own to this section to, just make a folder for the software name and put the necessary install steps in an `install.sh` file so that it can be easily added. Please take note that any dependencies must be copied to `/var/task` or they will not be in deployment package.

Custom installs should always come before the `deploy.sh` and `zip.sh` as python modules can fail without custom software already present. If you don't include it before the `zip.sh` nothing will be included in the zip.

### powershell

This script installs PowerShell to the system if you need it for development. Modify the Dockerfile to include it like so if you need PowerShell installed:

```Dockerfile
# install powershell
RUN chmod +x ./scripts/powershell/install.sh
RUN ./scripts/powershell/install.sh
```

### pyodbc / unixODBC

This script install unixODBC / pyodbc and required Microsoft Drivers. Modify the Dockerfile to include it like so if you need to make use of pyodbc. It should be noted this should come before the deploy.sh script:

```Dockerfile
# install pyodbc
RUN chmod +x ./scripts/pyodbc/install.sh
RUN ./scripts/pyodbc/install.sh
```

## Extracting the Zip from the Container

To extract files from the container, you can do so in a very simple command. 

First, find the name / container id of your container that built the deployment zip

```bash
docker ps
```

and run the following to copy the zip locally

```bash
docker cp <image_name>:/var/task/lambda-package.zip .
```

i.e.

```bash
docker cp pensive_khorana:/var/task/lambda-package.zip .
```

Or alternatively, use the script found in `utils\` called `ExtractZipFile.ps1`. This is an interactive script and will help you to extract the zip file. 
