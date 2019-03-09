#! /bin/bash
set -eE

echo "Building react native bundle..."
react-native bundle --platform ios --dev false --assets-dest ios --entry-file index.ios.js --bundle-output ios/main.jsbundle
zip -r react-native.zip ios/

BASE='https://dl.google.com/dl/cloudsdk/channels/rapid/'
NAME='google-cloud-sdk'
EXT='.tar.gz'
INSTALL=$HOME
BOOTSTRAP="$INSTALL/$NAME/bin/bootstrapping/install.py"
GCLOUD="$INSTALL/$NAME/bin/gcloud"

with_python27() {
    bash -c "source $HOME/virtualenv/python2.7/bin/activate; $1"
}

echo "Downloading Google Cloud SDK ..."
curl -L "${BASE}${NAME}${EXT}" | gzip -d | tar -x -C ${INSTALL}

echo "Bootstrapping Google Cloud SDK ..."
with_python27 "$BOOTSTRAP --usage-reporting=false --command-completion=false --path-update=false"

PATH=$PATH:$INSTALL/$NAME/bin/

echo "Configuring service account auth..."
gcloud -q auth activate-service-account --key-file ops/tbatv-prod-hrd-firebase-adminsdk.json

firebase_bucket="gs://$google_cloud_project.appspot.com"
gsutil cp react-native.zip $firebase_bucket/react-native/react-native.zip


