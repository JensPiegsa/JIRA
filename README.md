# JIRA #

This docker file provides a container with the latest JIRA version for testing purposes.

## Usage example

### 0. Prerequisites

* [Docker](http://docs.docker.com/windows/step_one/)

### 1a. Initialize a database

* `docker run --name=db -d -p 3306:3306 -v /etc/mysql:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD="root" -e MYSQL_DATABASE="jira" -e MYSQL_USER="jira" -e MYSQL_PASSWORD="jira" mysql:5.6`
* `ALTER SCHEMA jira  DEFAULT CHARACTER SET utf8  DEFAULT COLLATE utf8_bin;`

### 1b. Alternatively use a custom database schema

* Create MySQL database schema and user:

```sql
CREATE DATABASE IF NOT EXISTS `jira` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
CREATE USER 'jira'@'%' IDENTIFIED BY 'jira';
GRANT ALL ON `jira`.* TO 'jira'@'%';
FLUSH PRIVILEGES;
```

### 2. Create a custom data-only Docker container

(with a volume pointing to $JIRA_HOME)

* `docker run --name=jira-data -v /var/atlassian/jira piegsaj/jira:latest true`

### 3. Run JIRA ###

* `docker run --name=jira -d -p 8080:8080 --link=db:db --volumes-from jira-data -e CATALINA_OPTS="-Xms128m -Xmx2048m -Datlassian.darkfeature.jira.onboarding.feature.disabled=true -Datlassian.plugins.enable.wait=300" piegsaj/jira:latest`

### 4. Start up your browser

* target, e.g. `http://192.168.99.100:8080/`

## Recipes ##

### Disable Secure Administrator Sessions for dev / test environments ###

```
docker exec jira sh -c 'echo "jira.websudo.is.disabled = true" >>/var/atlassian/jira/jira-config.properties'
docker stop jira
docker start jira
```

### Re-new an evaluation license ###

* log in to [https://my.atlassian.com/products/](https://my.atlassian.com/products/) and press **New Evaluation License**
* you will need to enter your *Server ID* from **Administration > System > System info > Server ID**
* paste the generated license string into the license management of your instance

## See also ##

* [JIRA REST API Reference](https://docs.atlassian.com/jira/REST/ondemand/)
