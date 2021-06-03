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

app_name=$(cat $config_file | jq -r .packageName)

#   remove all previously generated files
shopt -s extglob 
echo "removing previous sdk: $sdk_output_folder"
rm -rf $sdk_output_folder/$app_name/!(utilities|tcp)
shopt -u extglob 

# ignore files
mkdir -p $sdk_output_folder
cp $ignore_file $sdk_output_folder

sdk_version=$(cat $swagger_file | jq -r '.info.version')
cat $config_file | jq -r --arg SDK_VERSION "$sdk_version" '.packageVersion |= $SDK_VERSION' > temp && mv temp $config_file

# remove the verbose description
cat $swagger_file | jq -r '.info.description |= "FINBOURNE Technology"' > temp && mv temp $swagger_file

echo "generating sdk version: $sdk_version"

# generate the SDK
java -jar openapi-generator-cli.jar generate \
    -i $swagger_file \
    -g python-legacy \
    -o $sdk_output_folder \
    -t $gen_root/templates \
    -c $config_file

    # enable the following if a manual override is required
    # --skip-validate-spec

# create a version file
cat << EOF > $sdk_output_folder/$app_name/__version__.py
__version__ = "$sdk_version"
EOF

rm -rf $sdk_output_folder/.openapi-generator/
rm -rf $sdk_output_folder/test/
rm -f $sdk_output_folder/.gitlab-ci.yml $sdk_output_folder/setup.cfg
rm -f $sdk_output_folder/.openapi-generator-ignore
rm -f $output_folder/.openapi-generator-ignore