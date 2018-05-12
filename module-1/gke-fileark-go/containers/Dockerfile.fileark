FROM debian:9.1

RUN apt-get update && apt-get install -y ca-certificates

COPY gopath/bin/fileark scripts/fileark.sh /

RUN chmod a+x /fileark.sh

ENTRYPOINT ["/fileark.sh"]
