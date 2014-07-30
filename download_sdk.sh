#!/bin/sh
echo "Downloading Open Peer iOS SDK ..."
cd plugins/org.openpeer.cordova/src/ios/
curl -v https://s3.amazonaws.com/assets.hookflash.me/github.com-openpeer-opios/OPiOS_SDK_Builds/OpenpeerSDK.C.1.0.18.framework.zip > OPSDK.zip
echo "Extracting the SDK into plugin folder ..."
unzip -o OPSDK.zip
mv OpenpeerSDK.C.1.0.18.framework/ OpenpeerSDK.framework
rm OPSDK.zip
echo "done."
