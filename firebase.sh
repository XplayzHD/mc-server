# download content

echo "downloading content..."

curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/functions/package.json -o package.json
curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/functions/index.js -o index.js

# install dependencies

echo "installing dependencies..."

npm i

echo "done."
