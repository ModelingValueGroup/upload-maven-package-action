#FROM alpine:3.10
FROM ubuntu:latest

LABEL author="Tom Brus"
LABEL "com.github.actions.name"="upload maven package"
LABEL "com.github.actions.description"="upload a file as a maven package to the github package registry"
LABEL "com.github.actions.icon"="package"
LABEL "com.github.actions.color"="purple"

#RUN	apk add --no-cache \
RUN apt-get update && apt-get install -y \
  bash \
  xmlstarlet \
  maven

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
