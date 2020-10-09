$ErrorActionPreference = "Stop"

#################################################
# DEFINE THE BELOW

# define lambda function details
$lambda_function_name = "TestPythonUpdate"
$UpdateLambdaFunctionCode = $false

################################################

# docker image named used
$docker_image_name = "lambda-builder"

# stop running containers
Write-Host("[*] Stopping running containers:")
Start-Process "cmd" -ArgumentList "/C FOR /f `"tokens=*`" %i IN ('docker ps -q') DO docker stop %i" -Wait


# delete previous images
Write-Host("[*] Removing old images with same name...")
Start-Process "cmd" -ArgumentList "/C docker image rm $docker_image_name -f" -Wait 
Start-Process "cmd" -ArgumentList "/C docker image prune -f" -Wait
Write-Host("  [+] Removed old images.")

# run the docker build
Write-Host("[*] Running docker image build...")
Start-Process "cmd" -ArgumentList "/C docker build . -t $docker_image_name" -Wait
Write-Host("  [+] Docker image build complete.")

# run the container
Write-Host("[*] Running container image in background...")
Start-Process "cmd" -ArgumentList "/C docker run --entrypoint `"/bin/sleep`" $docker_image_name 10"
Write-Host("  [+] Docker running image.")

# then extract the ZIP
Write-Host("[*] Extract the ZIP file.")
Start-Process "powershell" -ArgumentList "-file .\utils\ExtractZipFile.ps1" -NoNewWindow -Wait

If ($UpdateLambdaFunctionCode) {

    # finally update lambda function
    Start-Process "python" -ArgumentList "utils\update_lambda_function.py $lambda_function_name" -NoNewWindow -Wait

}
