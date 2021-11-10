#!/bin/bash -e

if [[ ${#1} -eq 0 ]]; then
    echo
    echo "[ERROR] generate folder file path not specified"
    exit 1
fi

if [[ ${#2} -eq 0 ]]; then
    echo
    echo "[ERROR] output folder file path not specified"
    exit 1
fi

if [[ ${#3} -eq 0 ]]; then
    echo
    echo "[ERROR] swagger file not specified"
    exit 1
fi

gen_root=$1
output_folder=$2
swagger_file=$output_folder/$3

sdk_output_folder=$output_folder/sdk

ignore_file_name=.openapi-generator-ignore
config_file_name=config.json
config_file=$gen_root/$config_file_name
ignore_file=$output_folder/$ignore_file_name

#   remove all previously generated files
shopt -s extglob
echo "removing previous sdk:"
rm -rf $sdk_output_folder/docs/
rm -rf $sdk_output_folder/src/
rm -rf $sdk_output_folder/api/
rm -rf $sdk_output_folder/model/
rm -rf $sdk_output_folder/test/api/
rm -rf $sdk_output_folder/test/model/
shopt -u extglob

# set version of the SDK
sdk_version=$(cat $swagger_file | jq -r '.info.version')
cat $config_file | jq -r --arg SDK_VERSION "$sdk_version" '.packageVersion |= $SDK_VERSION' > temp && mv temp $config_file

cp $ignore_file $sdk_output_folder

echo "generating sdk"
java -jar openapi-generator-cli.jar generate \
    -i $swagger_file \
    -g typescript-node \
    -o $sdk_output_folder \
    -c $config_file \
    -t $gen_root/templates \
    --additional-properties supportsES6=true

# update package.json
cat $sdk_output_folder/package.json | jq -r --arg SDK_VERSION "$sdk_version" '.version |= $SDK_VERSION' > temp && mv temp $sdk_output_folder/package.json

cd $sdk_output_folder

# workarounds for known issue - https://github.com/OpenAPITools/openapi-generator/issues/1139
echo "import { PropertyValue } from '../model/propertyValue';" > api/_portfoliosApi.ts
cat api/portfoliosApi.ts >> api/_portfoliosApi.ts
rm api/portfoliosApi.ts
mv api/_portfoliosApi.ts api/portfoliosApi.ts

# Create the api class for intellisense to work
cd api
# Get all the apis available (needed for preview vs non-preview)
apis=("$(ls -d *)")
apis=( "${apis[@]/apis.ts}" )
# Remove existing API class

cd ../
rm -f apis.ts
# Create new file
touch apis.ts

# Iterate over each API and build the API class

# Add the imports line by line
for api in ${apis[@]}
do
   :
   api="${api::-3}"
   api_upper=${api^}
   echo "$api_upper"
   echo "import {$api_upper} from './api/$api';" >> apis.ts
done

echo "" >> apis.ts
echo "export class Api {" >> apis.ts

# Add the class attributes line by line
for api in ${apis[@]}
do
   :
   api="${api::-3}"
   api_short="${api::-3}"
   api_upper="${api^}"
   echo "    public $api_short:  $api_upper" >> apis.ts
done

echo "}" >> apis.ts

# Move up directories for removal of files
cd ../../../

rm -rf $sdk_output_folder/.openapi-generator/
rm -f $sdk_output_folder/$ignore_file_name
rm -f $sdk_output_folder/README.md
rm -f $sdk_output_folder/.travis.yml
rm -f $sdk_output_folder/git_push.sh
rm -f $sdk_output_folder/.gitignore
rm -f $output_folder/.openapi-generator-ignore
           