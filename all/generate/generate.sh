#!/bin/bash -e


usage()
{
    echo
    echo "usage: $0 "
    echo
    echo "  -l  SDK language (csharp, java, javascript, python)"
    echo "  -u  url to swagger file"
    echo "  -f  path to swagger file"
    echo "  -o  output folder"
    echo "  -s  filename to save swagger file to"
    echo "  -n  SDK name"
    echo "  -c  SDK generation configuration file (optional)"
    echo "  -i  SDK generation ignore file (optional)"
    echo
    exit 1
}

while getopts 'l:u:f:s:o:n:c:i:' opt
do
  case $opt in
    l) lang=$OPTARG ;;
    u) url=$OPTARG ;;
    f) file=$OPTARG ;;
    o) output_folder=$OPTARG ;;
    s) swagger_file=$OPTARG ;;
    n) sdk_name=$OPTARG ;;
    c) config_file=$OPTARG ;;
    i) ignore_file=$OPTARG ;;
  esac
done

# verify parameters
[ -z "$lang" ] && usage
[ -z "$url" ] && [ -z "$file" ] && usage
[ -z "$swagger_file" ] && usage
[ -z "$output_folder" ] && usage
[ -z "$sdk_name" ] && usage

# copy custom config to generate folder
if [[ ! -z "$config_file" && -f "$config_file" ]] ; then
    echo "[INFO] copying $config_file to ../../$lang/generate"
    cp $config_file ../../$lang/generate
fi

# change to language folder
cd ../../$lang/generate

mkdir -p output/sdk

# copy the existing sdk to the working output folder, ignore errors of folder is empty
cp -R $output_folder/* ./output/ 2>/dev/null || :

rm -rf ./output/.git

if [[ $url == *"http"* ]]; then
    echo "[INFO] Using Swagger URL"
    
    curl -L $url -o $swagger_file
else
    echo "[INFO] No http in provided name, using local file"
    cp -f $file $swagger_file
fi

cp ../../all/generate/docker-compose.yml docker-compose.yml

cp ${ignore_file:=.openapi-generator-ignore} output/.openapi-generator-ignore

mv $sdk_name.json output/$sdk_name.json

# build the sdk
docker-compose build && docker-compose run lusid-sdk-gen ./generate/generate.sh ./generate ./generate/output \
    $(basename $swagger_file) $(basename $config_file)
docker-compose rm -f

rm -f docker-compose.yml

cp -R ./output/* $output_folder/

rm -rf output