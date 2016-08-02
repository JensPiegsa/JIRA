#!/bin/bash
export JIRA_VERSION=$(cat $JIRA_INSTALL/jira.version)
if [ ! -f ${JIRA_INSTALL}/conf/.docker_container_initialized ]; then
  echo "INTIZIALIZING JIRA VERSION $JIRA_VERSION..."
  touch ${JIRA_INSTALL}/conf/.docker_container_initialized
fi

# if this container is runned with --link=mysql:db use the environment variables provided by docker

[ -z $DB_TYPE ] && [ -n ${DB_PORT_3306_TCP} ] && DB_TYPE=MYSQL

DB_ADDRESS=${DB_PORT_3306_TCP_ADDR:=DB_ADDRESS}
DB_PORT=${DB_PORT_3306_TCP_PORT:=$DB_PORT}
DB_USER=${DB_ENV_MYSQL_USER:=$DB_USER}
DB_PASSWORD=${DB_ENV_MYSQL_PASSWORD:=$DB_PASSWORD}
DB_SCHEMA=${DB_ENV_MYSQL_DATABASE:=$DB_SCHEMA}

cp $JIRA_HOME/dbconfig-template.xml $JIRA_HOME/dbconfig.xml

sed -i \
-e "/${DB_TYPE}_TEMPLATE/d" \
-e "s/\$DB_ADDRESS/$DB_ADDRESS/" \
-e "s/\$DB_PORT/$DB_PORT/" \
-e "s/\$DB_SCHEMA/$DB_SCHEMA/" \
-e "s/\$DB_USER/$DB_USER/" \
-e "s/\$DB_PASSWORD/$DB_PASSWORD/" \
-e "s/\$DB_SSL/$DB_SSL/g" \
$JIRA_HOME/dbconfig.xml

echo "STARTING JIRA $JIRA_VERSION..."
exec /opt/atlassian/jira/bin/start-jira.sh -fg
