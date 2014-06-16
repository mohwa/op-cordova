#!/bin/sh

cd ./src/ios/OpenpeerSDK.framework/             && \
curl -v https://s3.amazonaws.com/assets.hookflash.me/github.com~hookflashco~hcs-stack-cordova/OpenpeerSDK_iOS_16June2014_v1.0.9.zip > OPSDK.zip && \
unzip -fov OPSDK.zip                                  && \
rm OPSDK.zip
