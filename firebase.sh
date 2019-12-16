ROOT=./mcserver-functions

mkdir $ROOT

# download content

echo "downloading content..."

curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/functions/package.json -o $ROOT/package.json
curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/functions/index.js -o $ROOT/index.js

# install dependencies

echo "installing dependencies..."

cd $ROOT && npm i

# upload functions

echo "uploading functions..."

firebase deploy --only functions

echo "done."
