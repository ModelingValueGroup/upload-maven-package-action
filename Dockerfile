FROM maven:3.6.0-jdk-12-alpine

LABEL author="Tom Brus"
LABEL "com.github.actions.name"="upload maven package"
LABEL "com.github.actions.description"="upload a file as a maven package to the github package registry"

RUN	apk add --no-cache \
  bash \
  xmlstarlet \
  jq \
  maven

COPY entrypoint.sh /entrypoint.sh
COPY functions.sh  /functions.sh

ENTRYPOINT ["/entrypoint.sh"]
