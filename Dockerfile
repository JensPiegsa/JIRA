FROM piegsaj/oracle-jre:latest

MAINTAINER Jens Piegsa (piegsa@gmail.com)

ENV MYSQL_CONNECTOR_VERSION 5.1.38

ENV JIRA_HOME               /var/atlassian/jira
ENV JIRA_INSTALL            /opt/atlassian/jira
ENV BUILD_PACKAGES          xmlstarlet curl jq
ENV RUNTIME_PACKAGES        libtcnative-1 augeas-tools

ADD dbconfig-template.xml                /tmp/
ADD adjust-log4j-properties.aug          /tmp/
ADD adjust-server-xml.aug                /
ADD adjust-server-xml-proxy-settings.aug /
ADD run-jira.sh                          /

RUN apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends ${RUNTIME_PACKAGES} ${BUILD_PACKAGES} && \
    apt-get clean -qq && \

    mkdir -p                ${JIRA_HOME} && \

    cp                      /tmp/dbconfig-template.xml ${JIRA_HOME}/dbconfig-template.xml && \

    chmod -R 700            ${JIRA_HOME} && \
    chown -R daemon:daemon  ${JIRA_HOME} && \
    mkdir -p                ${JIRA_INSTALL}/conf/Catalina && \
    mkdir -p                ${JIRA_INSTALL}/lib && \

    JIRA_VERSION=$(curl https://my.atlassian.com/download/feeds/current/jira-core.json -Ls | cut -b 11- | rev | cut -c 2- | rev | jq -r '.[] | select(.zipUrl | contains("tar.gz")) | select(.zipUrl | contains("source") | not) | .version') && \
    
    JIRA_DOWNLOAD_URL=$(curl https://my.atlassian.com/download/feeds/current/jira-core.json -Ls | cut -b 11- | rev | cut -c 2- | rev | jq -r '.[] | select(.zipUrl | contains("tar.gz")) | select(.zipUrl | contains("source") | not) | .zipUrl') && \
    
    echo ${JIRA_VERSION} >${JIRA_INSTALL}/jira.version && \

    curl -Ls                ${JIRA_DOWNLOAD_URL} | tar xz --directory=${JIRA_INSTALL} --strip-components=1 --no-same-owner && \
    curl -Ls                http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz | tar xz --directory=/tmp --no-same-owner && \

    cp                      /tmp/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar ${JIRA_INSTALL}/lib/ && \

    augtool -LeAf           /tmp/adjust-log4j-properties.aug -r ${JIRA_INSTALL}/ && \

    rm -R                   /tmp/* && \

    chmod -R 700            ${JIRA_INSTALL}/conf && \
    chmod -R 700            ${JIRA_INSTALL}/logs && \
    chmod -R 700            ${JIRA_INSTALL}/temp && \
    chmod -R 700            ${JIRA_INSTALL}/work && \
    chown -R daemon:daemon  ${JIRA_INSTALL}/conf && \
    chown -R daemon:daemon  ${JIRA_INSTALL}/logs && \
    chown -R daemon:daemon  ${JIRA_INSTALL}/temp && \
    chown -R daemon:daemon  ${JIRA_INSTALL}/work && \
    chmod +x                /run-jira.sh && \
    chown daemon:daemon     $JAVA_HOME/jre/lib/security/cacerts && \

    sed -i "/^jira.home =.*/c\jira.home = ${JIRA_HOME}" ${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties && \

    apt-get remove -qq --purge -y ${BUILD_PACKAGES} $(apt-mark showauto) && rm -rf /var/lib/apt/lists/*

USER daemon:daemon

EXPOSE 8080 8443

VOLUME ${JIRA_HOME}
VOLUME ${JIRA_INSTALL}/conf
VOLUME /etc/jira

WORKDIR ${JIRA_HOME}

CMD ["/run-jira.sh"]