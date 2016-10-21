transform Xml.lns incl server.xml
load
set /augeas/context /files/server.xml/Server/Service/Connector[1]/#attribute
set proxyName "$PROXY_NAME"
set proxyPort "$PROXY_PORT"
save
