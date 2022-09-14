FROM fedora

RUN dnf install 'dnf-command(config-manager)' -y && \
    dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo && \
    dnf install gh git -y

RUN curl -LO https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/pipeline/latest/tkn-linux-amd64.tar.gz && \
    tar xvzf tkn-linux-amd64.tar.gz && \
    mv tkn tkn-pac /usr/bin/

RUN curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz && \
    tar xvzf oc.tar.gz && \
    mv oc kubectl /usr/bin/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"] 
