"""For updating an existing Lambda function with the code located in S3

    This performs the S3 upload and lambda function code update.
"""
import boto3
import os
import sys

if len(sys.argv) == 2:
    # lambda details
    target_lambda_function_name = sys.argv[1]

else:
    # lambda details
    target_lambda_function_name = "TestPythonUpdate"
target_lambda_function_region = "us-east-1"
function_zip_path = 'lambda-package.zip'

# upload function zip to s3
def upload_lambda_package(function_zip_path, target_lambda_function_name):

    # build s3 details
    s3_key = 'lambda-functions/'+target_lambda_function_name+'/lambda-package.zip'
    s3_bucket = 'mkt-cfn-scripts'

    print('[*] Uploading lambda deployment package:\n\tS3Key: {}'.format(s3_key))

    # get zip content
    with open(function_zip_path, 'rb') as f:
        zip_content = f.read()
        f.close()

    # put the object
    s3_client = boto3.client('s3')
    s3_client.put_object(
        Bucket=s3_bucket,
        Key=s3_key,
        Body=zip_content
    )
    print('\t[+] Uploaded.')


# update lambda function with new ZIP file
def update_lambda_function(function_name, function_region):

    # build s3 details
    s3_key = 'lambda-functions/'+function_name+'/lambda-package.zip'
    s3_bucket = 'mkt-cfn-scripts'


    # build client to lambda
    lambda_client = boto3.client('lambda', region_name=function_region)

    print('[*] Updating Lambda function code...')

    # use client to update function code
    lambda_client.update_function_code(
        FunctionName=function_name,
        S3Bucket=s3_bucket,
        S3Key=s3_key,
        Publish=True
    )

    print('\t[+] Function code updated.')


def archive_zip(function_zip_path, function_name):

    # if archive folder does not exist
    if not os.path.exists('function-archive'):

        # create it
        os.mkdir('function-archive')
    
    # if function name folder does not exist
    if not os.path.exists('function-archive/{}'.format(function_name)):

        # create it
        os.mkdir('function-archive/{}'.format(function_name))

    # finally move the zip file
    os.rename(function_zip_path, 'function-archive/{0}/{1}'.format(function_name, function_zip_path))
    



# upload the ZIP file
upload_lambda_package(
    function_zip_path=function_zip_path,
    target_lambda_function_name=target_lambda_function_name
)


# update the function code
update_lambda_function(
    function_name=target_lambda_function_name,
    function_region=target_lambda_function_region
)

# archive the zip into folders
archive_zip(
    function_zip_path=function_zip_path,
    function_name=target_lambda_function_name
)