#!/bin/bash
export JIRA_VERSION=$(cat $JIRA_INSTALL/jira.version)

echo "STARTING JIRA VERSION $JIRA_VERSION..."

JIRA_CONF="${JIRA_INSTALL}/conf"

if [ ! -f ${JIRA_CONF}/.docker_container_initialized ] ; then
  echo "INITIALIZING..."
  
  # insert HTTPS connector if keystore is provided
  if [ ! -z "$KEYSTORE_FILE" ] ; then
    augtool -LeAf /opt/adjust-server-xml.aug -r ${JIRA_CONF}/

    sed -i 's@$KEYSTORE_FILE@'"$KEYSTORE_FILE"'@g' ${JIRA_CONF}/server.xml
    sed -i 's@$KEYSTORE_PASS@'"$KEYSTORE_PASS"'@g' ${JIRA_CONF}/server.xml
    sed -i 's@$KEY_ALIAS@'"$KEY_ALIAS"'@g' ${JIRA_CONF}/server.xml

    # insert optional proxy attributes to HTTPS connector
    if [ ! -z "$PROXY_NAME"] ; then
      augtool -LeAf /opt/adjust-server-xml-proxy-settings.aug -r ${JIRA_CONF}/
      sed -i 's@$PROXY_NAME@'"$PROXY_NAME"'@g' ${JIRA_CONF}/server.xml
      sed -i 's@$PROXY_PORT@'"$PROXY_PORT"'@g' ${JIRA_CONF}/server.xml
    fi

    # optionally import foreign SSL certificates that you trust
    if [ ! -z "${IMPORT_CERTS_DIR}" ] ; then
        CA_KEYSTORE="${JAVA_HOME}/jre/lib/security/cacerts"
        for CERT in "${IMPORT_CERTS_DIR}"/* ; do
            echo "IMPORTING CERT ${CERT}..."
            keytool -import -v -trustcacerts -alias "${CERT}" -file "${CERT}" \
                    -keystore "${CA_KEYSTORE}" -keypass changeit -storepass changeit -noprompt
        done
    fi
  fi

  touch ${JIRA_CONF}/.docker_container_initialized
fi

# if this container is instantiated with --link=mysql:db use the environment variables provided by docker
[ -z "$DB_TYPE" ] && [ ! -z "${DB_PORT_3306_TCP}" ] && DB_TYPE=MYSQL

DB_ADDRESS=${DB_PORT_3306_TCP_ADDR:=$DB_ADDRESS}
DB_PORT=${DB_PORT_3306_TCP_PORT:=$DB_PORT}
DB_USER=${DB_ENV_MYSQL_USER:=$DB_USER}
DB_PASSWORD=${DB_ENV_MYSQL_PASSWORD:=$DB_PASSWORD}
DB_SCHEMA=${DB_ENV_MYSQL_DATABASE:=$DB_SCHEMA}

cp ${JIRA_HOME}/dbconfig-template.xml ${JIRA_HOME}/dbconfig.xml

sed -i \
 -e "/${DB_TYPE}_TEMPLATE/d" \
 -e "s/\$DB_ADDRESS/$DB_ADDRESS/" \
 -e "s/\$DB_PORT/$DB_PORT/" \
 -e "s/\$DB_SCHEMA/$DB_SCHEMA/" \
 -e "s/\$DB_USER/$DB_USER/" \
 -e "s/\$DB_PASSWORD/$DB_PASSWORD/" \
 -e "s/\$DB_SSL/$DB_SSL/g" \
 $JIRA_HOME/dbconfig.xml

echo "STARTING JIRA SERVER..."
exec ${JIRA_INSTALL}/bin/start-jira.sh -fg
