# Dockerfile for JIRA EAP #

## Usage example ##

### 0. Prerequisites ###

* Docker [(installation guide)](http://docs.docker.com/windows/step_one/)

### 1. Initialize a database ###

* `docker run --name=jiradb -d -p 3306:3306 -v /etc/mysql:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD="root" -e MYSQL_DATABASE="jira" -e MYSQL_USER="jira" -e MYSQL_PASSWORD="jira" mysql:5.6`

### 2. Create a custom data-only Docker container ###

* `docker run --name=jira-data -v /var/atlassian/jira piegsaj/jira:latest true`

### 3. Run JIRA ###

* `docker run --name=jira -d -p 8080:8080 --link=jiradb:db --volumes-from jira-data -e CATALINA_OPTS="-Xms128m -Xmx2048m -Datlassian.darkfeature.jira.onboarding.feature.disabled=true -Datlassian.plugins.enable.wait=300" piegsaj/jira:latest`

### 4. Start up your browser ###

* target, e.g. `http://192.168.99.100:8080/`
