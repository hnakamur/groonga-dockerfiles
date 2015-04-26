FROM ubuntu:14.04.2

RUN sudo apt-get -y install software-properties-common && \
    sudo add-apt-repository -y universe && \
    sudo add-apt-repository -y ppa:groonga/ppa && \
    sudo apt-get update && \
    sudo apt-get -y install groonga \
        groonga-tokenizer-mecab \
        groonga-token-filter-stem \
        groonga-httpd && \
    sudo mkdir -p /var/run/groonga && \
    sudo sed -i 's/^ENABLE=yes$/ENABLE=no/' /etc/default/groonga-httpd

EXPOSE 10041
CMD ["/usr/sbin/groonga-httpd", "-g", "daemon off;"]
