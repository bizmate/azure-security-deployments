FROM httpd:2.4.58
MAINTAINER Diego Gullo <diego_gullo@bizmate.biz>

RUN apt-get update && apt-get install -y curl \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY filebeat-template.yml /opt/filebeat-template.yml

RUN curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.12.2-amd64.deb \
    && dpkg -i filebeat-8.12.2-amd64.deb \
    && cd /etc/filebeat && mv filebeat.yml filebeat.yml_backup 2>/dev/null \
    && cp /opt/filebeat-template.yml /etc/filebeat/filebeat.yml \
    && filebeat modules enable system && filebeat modules enable apache

RUN chmod -R 644 /var/lib/filebeat/ && chown -R www-data /var/lib/filebeat/ #&& filebeat setup
