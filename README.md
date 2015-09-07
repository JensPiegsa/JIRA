# Dockerfile for JIRA EAP #

## Usage example ##

### 0. Prerequisites ###

* [Docker](http://docs.docker.com/windows/started/)

### 1. Initialize a database ###

* `docker run --name=jiradb -d -p 3306:3306 -v /etc/mysql:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD="root" -e MYSQL_DATABASE="jira" -e MYSQL_USER="jira" -e MYSQL_PASSWORD="jira" mysql:5.6`

### 2. Run JIRA ###

* `docker run --name=jira -d -p 8080:8080 --link=jiradb:db -v /c/Users/piegsaj/jira-home:/var/atlassian/jira -e CATALINA_OPTS="-Xms128m -Xmx2048m -Datlassian.darkfeature.jira.onboarding.feature.disabled=true -Datlassian.plugins.enable.wait=300" piegsaj/jira:latest`

### 3. Start up your browser ###

* target, e.g. `http://192.168.99.100:8080/`
