#!/bin/bash

export JIRA_VERSION=$(cat $JIRA_INSTALL/jira.version)

echo "STARTING JIRA VERSION $JIRA_VERSION..."

if [ ! -f ${JIRA_INSTALL}/conf/.docker_container_initialized ]; then
  echo "INITIALIZING..."

  # insert HTTPS connector if keystore is provided  
  if [ ! -z "$KEYSTORE_FILE" ]; then
    augtool -LeAf /adjust-server-xml.aug -r ${JIRA_INSTALL}/

    sed -i 's@$KEYSTORE_FILE@'"$KEYSTORE_FILE"'@g' ${JIRA_INSTALL}/server.xml
    sed -i 's@$KEYSTORE_PASS@'"$KEYSTORE_PASS"'@g' ${JIRA_INSTALL}/server.xml
    sed -i 's@$KEY_ALIAS@'"$KEY_ALIAS"'@g' ${JIRA_INSTALL}/server.xml
    
    # insert optional proxy attributes to HTTPS connector
    if [ ! -z "$PROXY_NAME"]; then
      augtool -LeAf /adjust-server-xml-proxy-settings.aug -r ${JIRA_INSTALL}/
      sed -i 's@$PROXY_NAME@'"$PROXY_NAME"'@g' ${JIRA_INSTALL}/server.xml
      sed -i 's@$PROXY_PORT@'"$PROXY_PORT"'@g' ${JIRA_INSTALL}/server.xml
    fi
 
  fi

  touch ${JIRA_INSTALL}/conf/.docker_container_initialized
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

echo "STARTING JIRA SERVER ..."
exec ${JIRA_INSTALL}/bin/start-jira.sh -fg
