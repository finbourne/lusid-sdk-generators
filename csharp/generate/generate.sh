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
sdk_config=$4
sdk_output_folder=$output_folder/sdk

ignore_file_name=.openapi-generator-ignore
config_file_name="${sdk_config:=config.json}"

config_file=$gen_root/$config_file_name
ignore_file=$output_folder/$ignore_file_name

app_name=$(cat $config_file | jq -r .packageName)

#   remove all previously generated files
shopt -s extglob 
echo "removing previous sdk:"
rm -rf $sdk_output_folder/$app_name/!(Utilities|*.csproj)
shopt -u extglob 

# ignore files
mkdir -p $sdk_output_folder
cp $ignore_file $sdk_output_folder

# set versions
sdk_version=$(cat $swagger_file | jq -r '.info.version')

echo "setting version to $sdk_version"

cat $config_file | jq -r --arg SDK_VERSION "$sdk_version" '.packageVersion |= $SDK_VERSION' > temp && mv temp $config_file
sed -i 's/<Version>.*<\/Version>/<Version>'$sdk_version'<\/Version>/g' $sdk_output_folder/$app_name/$app_name.csproj

echo "generating sdk"

#java -jar swagger-codegen-cli.jar swagger-codegen-cli help
java -jar openapi-generator-cli.jar generate \
    -i $swagger_file \
    -g csharp \
    -o $sdk_output_folder \
    -c $config_file \
	--type-mappings dateorcutlabel=DateTimeOrCutLabel \
  --type-mappings double=decimal

rm -rf $sdk_output_folder/.openapi-generator
rm -f $sdk_output_folder/.openapi-generator-ignore
rm -f $sdk_output_folder/.gitignore
rm -f $sdk_output_folder/git_push.sh
rm -f $sdk_output_folder/README.md
rm -f $output_folder/.openapi-generator-ignore