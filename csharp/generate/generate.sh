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
config_file_name=$4
sdk_output_folder=$output_folder/sdk

if [[ -z $config_file_name || ! -f $gen_root/$config_file_name ]] ; then
    echo "[INFO] '$config_file_name' not found, using default config.json"
    config_file_name=config.json
fi

echo "[INFO] root generation : $gen_root"
echo "[INFO] output folder   : $output_folder"
echo "[INFO] swagger file    : $swagger_file"
echo "[INFO] config file     : $config_file_name"

ignore_file_name=.openapi-generator-ignore
config_file=$gen_root/$config_file_name
ignore_file=$output_folder/$ignore_file_name

app_name=$(cat $config_file | jq -r .packageName)

#   remove all previously generated files
shopt -s extglob 
echo "[INFO] removing previous sdk:"
rm -rf $sdk_output_folder/$app_name/!(Utilities|*.csproj)
shopt -u extglob 

# ignore files
mkdir -p $sdk_output_folder
cp $ignore_file $sdk_output_folder

# set versions
sdk_version=$(cat $swagger_file | jq -r '.info.version')

echo "[INFO] setting version to $sdk_version"

cat $config_file | jq -r --arg SDK_VERSION "$sdk_version" '.packageVersion |= $SDK_VERSION' > temp && mv temp $config_file
sed -i 's/<Version>.*<\/Version>/<Version>'$sdk_version'<\/Version>/g' $sdk_output_folder/$app_name/$app_name.csproj

echo "[INFO] generating sdk"

#java -jar swagger-codegen-cli.jar swagger-codegen-cli help
java -jar openapi-generator-cli.jar generate \
    -i $swagger_file \
    -g csharp-netcore \
    -o $sdk_output_folder \
    -c $config_file \
    -t $gen_root/templates \
	--type-mappings dateorcutlabel=DateTimeOrCutLabel \
  --type-mappings double=decimal

rm -rf $sdk_output_folder/.openapi-generator
rm -f $sdk_output_folder/.openapi-generator-ignore
rm -f $sdk_output_folder/.gitignore
rm -f $sdk_output_folder/git_push.sh
rm -f $sdk_output_folder/README.md
rm -rf $sdk_output_folder/src
rm -f $output_folder/.openapi-generator-ignore