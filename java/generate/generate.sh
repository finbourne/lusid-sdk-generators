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
echo "removing previous sdk"
rm -rf $sdk_output_folder/docs
rm -rf $sdk_output_folder/target
rm -rf $sdk_output_folder/src/main/java/com/finbourne/lusid/!(utilities)
rm -rf $sdk_output_folder/src/test/java/com/finbourne/lusid/api
rm -rf $sdk_output_folder/src/test/java/com/finbourne/lusid/model
shopt -u extglob

mkdir -p $sdk_output_folder
cp $ignore_file $sdk_output_folder

java -jar openapi-generator-cli.jar generate \
    -i $swagger_file \
    -g java \
    -o $sdk_output_folder \
    -c $config_file \
    -t $gen_root/templates

# remove redundant generated build files
rm -f $sdk_output_folder/.openapi-generator-ignore
rm -rf $sdk_output_folder/.openapi-generator/
rm -rf $sdk_output_folder/gradle/
rm -rf $sdk_output_folder/.gitignore
rm -f $sdk_output_folder/.travis.yml
rm -f $sdk_output_folder/build.gradle
rm -f $sdk_output_folder/build.sbt
rm -f $sdk_output_folder/git_push.sh
rm -f $sdk_output_folder/gradle.properties
rm -f $sdk_output_folder/gradlew
rm -f $sdk_output_folder/gradlew.bat
rm -f $sdk_output_folder/settings.gradle
rm -f $sdk_output_folder/src/main/AndroidManifest.xml
rm -rf $sdk_output_folder/src/test/java/com/finbourne/lusid/api
rm -rf $sdk_output_folder/src/test/java/com/finbourne/lusid/model

# update pom version
sdk_version=$(cat $swagger_file | jq -r '.info.version')
mvn -f $sdk_output_folder/pom.xml versions:set -DnewVersion=$sdk_version-SNAPSHOT
rm -f $output_folder/.openapi-generator-ignore
rm -f $sdk_output_folder/README.md
rm -f $output_folder/api
rm -f $sdk_output_folder/pom.xml.versionsBackup
