#!/bin/bash

ES_ADDR=elasticsearch-example-es-cluster.elasticsearch.svc.cluster.local:9200
MYSQL_ADDR=catalogue-db.sock-shop.svc.cluster.local:3306

function cleanup() {
  kubectl -n elasticsearch delete pod logstash >/dev/null 2>&1
}
trap cleanup EXIT

echo "INFO: Ingesting data from mysql: ${MYSQL_ADDR} to Elasticsearch: ${ES_ADDR}"

kubectl run -n elasticsearch logstash -i --rm --restart=Never --command bash --image docker.elastic.co/logstash/logstash:6.2.4 -- -c '
curl -LO https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.36/mysql-connector-java-5.1.36.jar
cat > logstash.conf <<EOF
input {
  jdbc { 
    jdbc_connection_string => "jdbc:mysql://'${MYSQL_ADDR}'/socksdb"
    # The user we wish to execute our statement as
    jdbc_user => "root"
    jdbc_password => "fake_password"
    # The path to our downloaded jdbc driver
    jdbc_driver_library => "/usr/share/logstash/mysql-connector-java-5.1.36.jar"
    jdbc_driver_class => "com.mysql.jdbc.Driver"
    # our query
    statement => "SELECT * FROM sock"
    }
  }
output {
  stdout { codec => json_lines }
  elasticsearch {
  "hosts" => "'${ES_ADDR}'"
  "ssl" => true
  "ssl_certificate_verification" => false
  "index" => "socks"
  "document_type" => "sock"
  }
}
EOF
bin/logstash -f logstash.conf
echo "INFO: Ingest complete!"
'