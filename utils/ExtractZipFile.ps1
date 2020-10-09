# Extract the Lambda Package .zip

# ask user for container name
$containerName = docker container ls --latest --format "{{.Names}}"

# copy the file
docker cp "${containerName}:/lambda-package.zip" .

# wait for 10 seconds
Start-Sleep -Seconds 10