#!/bin/bash -e

if [[ (${#1} -eq 0) ]] ; then
    echo
    echo "[ERROR] missing API key"
    exit 1
fi

if [[ (${#2} -eq 0) ]] ; then
    echo
    echo "[ERROR] missing repo URL"
    exit 1
fi

api_key=$1
repo_url=$2

sdk_version=$(cat lusid.json | jq -r '.info.version')

cd sdk

# check the SDK does build
npm install
npm run build

cat > .npmrc <<EOF
//$repo_url:_authToken=$api_key
EOF

echo "sdk_version=$sdk_version"

npm pack
npm publish --registry=https://$repo_url --access public

cd ..

rm -f publish.sh