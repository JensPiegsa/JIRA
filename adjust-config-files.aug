transform Properties.lns incl /atlassian-jira/WEB-INF/classes/log4j.properties
load
set /augeas/context /files/atlassian-jira/WEB-INF/classes/log4j.properties
set log4j.logger.org.apache.catalina.webresources.Cache "ERROR, console, filelog"
save 
