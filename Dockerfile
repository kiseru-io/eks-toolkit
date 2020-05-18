FROM alpine:latest
 
MAINTAINER kiseru.io

RUN apk update && apk add curl jq

# install eksctl
ENV DOWNLOAD_URL_EKSCTL="https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_Linux_amd64.tar.gz" 
RUN curl --location --retry 5  "$DOWNLOAD_URL_EKSCTL" -o eksctl_download.tar.gz && \
    tar xzvf eksctl_download.tar.gz && rm eksctl_download.tar.gz && chmod +x ./eksctl && mv ./eksctl /usr/local/bin/

RUN eksctl version

# install aws-iam-authenticator 
# https://api.github.com/repos/kubernetes-sigs/aws-iam-authenticator/releases/latest --
ENV DOWNLOAD_URL_IAM="https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.0/aws-iam-authenticator_0.5.0_linux_amd64"
RUN curl -L -o aws-iam-authenticator "$DOWNLOAD_URL_IAM" \
    && chmod +x ./aws-iam-authenticator \
    && mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
