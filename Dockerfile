FROM alpine:latest
 
MAINTAINER kiseru.io

RUN apk update && apk add curl jq libc6-compat go \
    && wget $(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep browser_download_url | grep linux_amd64 | cut -d '"' -f 4) -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq

# install eksctl
ENV DOWNLOAD_URL_EKSCTL="https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_Linux_amd64.tar.gz" 
RUN curl --location --retry 5  "$DOWNLOAD_URL_EKSCTL" -o eksctl_download.tar.gz \
    && tar xzvf eksctl_download.tar.gz && rm eksctl_download.tar.gz \
    && chmod +x ./eksctl && mv ./eksctl /usr/local/bin/

RUN echo "==>" && eksctl version

# install aws-iam-authenticator 
# https://api.github.com/repos/kubernetes-sigs/aws-iam-authenticator/releases/latest --
ENV DOWNLOAD_URL_IAM="https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.0/aws-iam-authenticator_0.5.0_linux_amd64"
RUN curl -sL -o aws-iam-authenticator "$DOWNLOAD_URL_IAM" \
    && chmod +x ./aws-iam-authenticator \
    && mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

# install kustomize, pinned to v3.2.3
ENV KUSTOMIZE_VERSION="3.2.3"
RUN curl -sLO "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.2.3/kustomize_kustomize.v${KUSTOMIZE_VERSION}_linux_amd64" \
    && chmod +x ./kustomize_kustomize.v${KUSTOMIZE_VERSION}_linux_amd64 \
    && mv ./kustomize_kustomize.v${KUSTOMIZE_VERSION}_linux_amd64 /usr/local/bin/kustomize

RUN GO111MODULE=on go get sigs.k8s.io/kustomize/kustomize/v3@v3.2.3

RUN echo "==>" && kustomize version

# install kubectl
ENV KUBECTL_VERSION=1.18.0
RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

RUN echo "==>" && kubectl version --client

# TODO Fix versioning on next release. Note: libc6-compat required to run kfctl on alpine see https://github.com/kubeflow/kfctl/issues/333
ENV KFCTL_VERSION=1.0.2
RUN curl -sLO "https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz" \
    && tar xvf kfctl_v1.0.2-0-ga476281_linux.tar.gz && chmod +x kfctl \
    && mv kfctl /usr/local/bin/kfctl

RUN echo "==>" &&  kfctl version

# Add awscli
RUN apk --no-cache update && \
    apk --no-cache add python py-pip py-setuptools ca-certificates curl groff less && \
    pip --no-cache-dir install awscli && \
    rm -rf /var/cache/apk/*

RUN echo "==>" && aws --version
