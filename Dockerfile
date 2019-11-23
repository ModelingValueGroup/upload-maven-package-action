#FROM alpine:3.10
#FROM ubuntu:latest
FROM maven:3.6.0-jdk-12-alpine

LABEL author="Tom Brus"
LABEL "com.github.actions.name"="upload maven package"
LABEL "com.github.actions.description"="upload a file as a maven package to the github package registry"
LABEL "com.github.actions.icon"="package"
LABEL "com.github.actions.color"="purple"

#RUN apt-get update && apt-get install -y \
RUN	apk add --no-cache \
  bash \
  xmlstarlet \
  jq \
  maven

COPY entrypoint.sh /entrypoint.sh
COPY functions.sh  /functions.sh

ENTRYPOINT ["/entrypoint.sh"]
