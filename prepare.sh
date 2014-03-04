#!/bin/sh

cd ./src/ios/OpenpeerSDK.framework/             && \
curl -v https://s3.amazonaws.com/assets.hookflash.me/github.com-openpeer-opios-cordova/OpenpeerSDK.zip > OPSDK.zip && \
unzip -fov OPSDK.zip                                  && \
rm OPSDK.zip

