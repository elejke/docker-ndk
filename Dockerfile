FROM openjdk:8-jdk 
MAINTAINER German Novikov <german.novikov@phystech.edu>

ENV ANDROID_TARGET_SDK="29"
ENV ANDROID_BUILD_TOOLS_VERSION="29.0.2"
ENV ANDROID_SDK_TOOLS="26.1.1"
ENV ANDROID_NDK_VERSION="21.0.6113669"
ENV CMAKE_VERSION="3.10.2.4988404"

# install required libs, python3, android-sdk and android-ndk
RUN apt-get --quiet update --yes && \
apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1 locales apt-transport-https curl gnupg python3.7 && \
ln -s /usr/bin/python3.7 /usr/bin/python3 && \
mkdir -p /root/.android && touch /root/.android/repositories.cfg && \
mkdir android-sdk && \
chmod 777 android-sdk && \
cd android-sdk && \
wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
unzip android-sdk.zip && \
cd tools/bin && \
echo y | ./sdkmanager "platforms;android-${ANDROID_TARGET_SDK}" && \
echo y | ./sdkmanager "platform-tools" && \
echo y | ./sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" && \
echo y | ./sdkmanager "cmake;${CMAKE_VERSION}" && \ 
echo y | ./sdkmanager "ndk;${ANDROID_NDK_VERSION}" && \
chmod -R 777 /android-sdk && \
ln -s /android-sdk/ /usr/local/share/android-sdk

# install bazel and adb:
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg && \
mv bazel.gpg /etc/apt/trusted.gpg.d/ && \
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list && \
apt --quiet update --yes  && apt install --quiet bazel --yes && \
apt-get --quiet install android-tools-adb android-tools-fastboot --yes

RUN update-ca-certificates

ENV ANDROID_HOME $PWD/android-sdk 
ENV ANDROID_BUILD_TOOLS $PWD/android-sdk/build-tools/${ANDROID_BUILD_TOOLS_VERSION}/ 
ENV PATH="${PATH}:${ANDROID_HOME}:${ANDROID_BUILD_TOOLS}" 
