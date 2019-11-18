FROM alpine:latest
LABEL author="Tom Brus"

LABEL "com.github.actions.name"="upload maven package"
LABEL "com.github.actions.description"="upload a file as a maven package to the github package registry"
LABEL "com.github.actions.icon"="package"
LABEL "com.github.actions.color"="purple"

RUN	apk add --no-cache \
  bash \
  xmlstarlet

COPY action.sh /usr/bin/action.sh

ENTRYPOINT ["action.sh"]