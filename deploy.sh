#!/bin/bash

port=8080

docker build -t jenkins .
docker rm gallent_jones -f
# docker run --name gallent_jones -d -p 8080:8080 -p 50001:50000 -v jenkins_home:/var/jenkins_home jenkins
docker run --name gallent_jones \
       --network host \
       -d \
       -p $port:8080 \
       -p 50001:50000 \
       -v jenkins_home:/var/jenkins_home \
       -v /var/run/docker.sock:/var/run/docker.sock \
       jenkins \
       --httpPort=-1 \
       --httpsPort=$port \
       --httpsKeyStore=/var/jenkins_home/jenkins_keystore.jks \
       --httpsKeyStorePassword=jenkins
