FROM piegsaj/oracle-jre:latest

# Configuration variables.
ENV MYSQL_CONNECTOR_VERSION 5.1.36
ENV JIRA_HOME               /var/atlassian/jira
ENV JIRA_INSTALL            /opt/atlassian/jira

ENV BUILD_PACKAGES          augeas-tools xmlstarlet curl jq

ADD run-jira.sh             /usr/bin/run-jira.sh
ADD dbconfig-template.xml   /tmp/dbconfig-template.xml
ADD adjust-config-files.aug /tmp/adjust-config-files.aug

# Install Atlassian JIRA, some helper tools and setup initial home directory structure.
RUN apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends libtcnative-1 $BUILD_PACKAGES && \
    apt-get clean -qq && \

    mkdir -p                "${JIRA_HOME}" && \

    cp                      /tmp/dbconfig-template.xml $JIRA_HOME/dbconfig-template.xml && \

    chmod -R 700            "${JIRA_HOME}" && \
    chown -R daemon:daemon  "${JIRA_HOME}" && \
    mkdir -p                "${JIRA_INSTALL}/conf/Catalina" && \
    mkdir -p                "${JIRA_INSTALL}/lib" && \

    JIRA_VERSION=$(curl https://my.atlassian.com/download/feeds/eap/jira.json -Ls | cut -b 11- | rev | cut -c 2- | rev | jq -r '.[] | select(.zipUrl | contains("tar")) | select(.description|contains("WAR") | not) | .version') && \
    echo $JIRA_VERSION >$JIRA_INSTALL/jira.version && \

    curl -Ls                "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${JIRA_VERSION}.tar.gz" | tar xz --directory="${JIRA_INSTALL}" --strip-components=1 --no-same-owner && \
    curl -Ls                "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz" | tar xz --directory="/tmp" --no-same-owner && \

    cp                      /tmp/mysql-connector-java-$MYSQL_CONNECTOR_VERSION/mysql-connector-java-$MYSQL_CONNECTOR_VERSION-bin.jar $JIRA_INSTALL/lib/ && \

    augtool -LeAf /tmp/adjust-config-files.aug -r $JIRA_INSTALL/ && \

    rm -R                   /tmp/* && \

    chmod -R 700            "${JIRA_INSTALL}/conf" && \
    chmod -R 700            "${JIRA_INSTALL}/logs" && \
    chmod -R 700            "${JIRA_INSTALL}/temp" && \
    chmod -R 700            "${JIRA_INSTALL}/work" && \
    chown -R daemon:daemon  "${JIRA_INSTALL}/conf" && \
    chown -R daemon:daemon  "${JIRA_INSTALL}/logs" && \
    chown -R daemon:daemon  "${JIRA_INSTALL}/temp" && \
    chown -R daemon:daemon  "${JIRA_INSTALL}/work" && \
    chmod +x                /usr/bin/run-jira.sh && \

    sed -i "/^jira.home =.*/c\jira.home = ${JIRA_HOME}" ${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties && \

    apt-get remove -qq --purge -y $BUILD_PACKAGES $(apt-mark showauto) && rm -rf /var/lib/apt/lists/* && \

    sudo adduser daemon sudo

# Use the default unprivileged account. This could be considered bad practice on systems where
# multiple processes end up being executed by 'daemon' but with Docker we only ever run one process anyway.
USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 8080

# Set volume mount points for installation and home directory. Changes to the home directory need
# to be persisted as well as parts of the installation directory due to eg. logs.
VOLUME ["/var/atlassian/jira"]

# Set the default working directory to JIRA_HOME.
WORKDIR ${JIRA_HOME}

# Run Atlassian JIRA as a foreground process by default.
CMD ["run-jira.sh"]