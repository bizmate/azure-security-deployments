FROM httpd:2.4.58
MAINTAINER Diego Gullo <diego_gullo@bizmate.biz>

RUN apt-get update && apt-get install -y curl \
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.0-amd64.deb \
    && dpkg -i filebeat-7.4.0-amd64.deb \
    && cd /etc/filebeat && mv filebeat.yml filebeat.yml_backup 2>/dev/null \
    && curl -L -o filebeat.yml https://raw.githubusercontent.com/bizmate/azure-security-deployments/main/siem-and-monitoring-alerts/filebeat-template.yml  \
    && sed -i 's/SIEM_ELASTICSEARCH_HOST/elasticsearch/g' filebeat.yml \
    && filebeat modules enable system && filebeat modules enable apache #&& filebeat setup
