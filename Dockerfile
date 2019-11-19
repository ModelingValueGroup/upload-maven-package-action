#FROM alpine:latest
FROM alpine:3.10

LABEL author="Tom Brus"
LABEL "com.github.actions.name"="upload maven package"
LABEL "com.github.actions.description"="upload a file as a maven package to the github package registry"
LABEL "com.github.actions.icon"="package"
LABEL "com.github.actions.color"="purple"

#RUN	apk add --no-cache \
#  bash \
#  xmlstarlet

COPY entrypoint.sh /entrypoint.sh

RUN ls -l
RUN pwd
RUN /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
