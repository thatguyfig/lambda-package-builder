# Extract the Lambda Package .zip

# show all containers
docker container ls

# ask user for container name
$containerName = Read-Host -Prompt "What is the name of your container? e.g. noun_verb"

# copy the file
docker cp "${containerName}:/lambda-package.zip" .