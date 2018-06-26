FROM jenkins/jenkins:lts

USER root
RUN apt-get update && \
    apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository \
         "deb [arch=amd64] https://download.docker.com/linux/debian \
         $(lsb_release -cs) \
         stable" && \
    apt-get update && \
    apt-get -y install docker-ce

RUN curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) \
    -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

## get latest versions at https://developer.android.com/studio/index.html
RUN wget https://dl.google.com/android/repository/tools_r25.2.3-linux.zip -O /opt/android-sdk.zip
RUN mkdir /opt/android-sdk-linux
RUN chmod -R 755 /opt/android-sdk-linux
RUN unzip /opt/android-sdk.zip -d /opt/android-sdk-linux
RUN rm /opt/android-sdk.zip

## configure profile and environment variables
RUN >/etc/profile.d/android.sh
RUN sed -i '$ a\export ANDROID_HOME="/opt/android-sdk-linux"' /etc/profile.d/android.sh
RUN sed -i '$ a\export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH"' /etc/profile.d/android.sh
RUN . /etc/profile

## install Android SDK, auto-accepting terms of service
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | /opt/android-sdk-linux/tools/android update sdk --no-ui --all --filter platform-tools,android-25,build-tools-25.0.2,android-24,build-tools-24.0.1,android-23,build-tools-23.0.3,android-21,build-tools-21.1.2,tools,extra-android-support,extra-android-m2repository

ENV ANDROID_HOME /opt/android-sdk-linux

# Update SDK
# This is very important. Without this, your builds wouldn't run. Your image would aways get this error:
# You have not accepted the license agreements of the following SDK components:
# [Android SDK Build-Tools 24, Android SDK Platform 24]. Before building your project,
# you need to accept the license agreements and complete the installation of the missing
# components using the Android Studio SDK Manager. Alternatively, to learn how to transfer the license agreements
# from one workstation to another, go to http://d.android.com/r/studio-ui/export-licenses.html

#So, we need to add the licenses here while it's still valid.
# The hashes are sha1s of the licence text, which I imagine will be periodically updated, so this code will
# only work for so long.
RUN mkdir "$ANDROID_HOME/licenses" || true
RUN printf "\n8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > "$ANDROID_HOME/licenses/android-sdk-license"
RUN printf "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license"

RUN apt-get clean