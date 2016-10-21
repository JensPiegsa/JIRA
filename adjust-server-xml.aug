transform Xml.lns incl server.xml
load
set /augeas/context /files/server.xml/Server/Service
ins Connector before Connector[1]
set /augeas/context /files/server.xml/Server/Service/Connector[1]/#attribute
set port "8443"
set protocol "org.apache.coyote.http11.Http11Nio2Protocol"
set maxHttpHeaderSize "8192"
set minSpareThreads "25"
set maxThreads "150"
set enableLookups "false"
set disableUploadTimeout "true"
set acceptCount "100"
set useBodyEncodingForURI "true"
set SSLEnabled "true"
set scheme "https"
set secure "true"
set keystoreFile "$KEYSTORE_FILE"
set keystorePass "$KEYSTORE_PASS"
set keystoreType "JKS"
set keyAlias "$KEY_ALIAS"
set clientAuth "false"
set sslProtocol "TLS"
save
