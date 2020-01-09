# Script to help install the git repo correctly.
$gitRepoURL = "https://github.com/username/project.git"

# cd to script location
Set-Location $PSScriptRoot\..\code

# clear any existing goods
Get-ChildItem $codeFolder -Recurse | Remove-Item -Recurse -Force

# get the folder object
$codeFolder = Get-Item -Path $PSScriptRoot\..\code

# build temp folder path
$tempFolderPath = $codeFolder.FullName + "\temp"

# make folder
New-Item -ItemType Directory -Path $tempFolderPath -Force

# get temp folder object
$tempFolder = Get-Item -Path $tempFolderPath

# clone the new repo
git clone $gitRepoURL

# move everything from git folder to temp
$gitFolder = Get-ChildItem -Path $codeFolder | Where-Object {$_.Name -ne "temp"}
Get-ChildItem -Path $gitFolder.FullName -Recurse | Move-Item -Destination $tempFolder

# delete git folder
Remove-Item $gitFolder.FullName -Recurse -Force

# move everything from temp to code
Get-ChildItem -Path $tempFolder.FullName -Recurse | Move-Item -Destination $codeFolder

# remove temp folder
Remove-Item $tempFolder.FullName -Recurse -Force


