FROM openjdk:8u131-jdk-alpine as prod

ENV VERSION 4.0.2

WORKDIR /tmp

RUN adduser -S cantaloupe

# Install confd
# Download  Java Advanced Imaging API  from http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-java-client-419417.html
RUN apk add --update --no-cache openssl && \
  wget -q -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 && \
  wget https://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-i586.tar.gz && \
  chmod +x /usr/local/bin/confd && \
  mkdir -p /etc/confd/templates && \
  mkdir /etc/confd/conf.d && \ 
  tar -xvzpf jai-1_1_3-lib-linux-i586.tar.gz && \
  rm -rf jai-1_1_3-lib-linux-i586.tar.gz && \
  apk del openssl

ENV JAIHOME /tmp/jai-1_1_3/lib
ENV CLASSPATH $JAIHOME/jai_core.jar:$JAIHOME/jai_codec.jar:$JAIHOME/mlibwrapper_jai.jar:$CLASSPATH
ENV LD_LIBRARY_PATH .:$JAIHOME:$CLASSPATH

# Temporary build of fixed openjpeg-tools
RUN  apk add --update --no-cache git libpng-dev tiff-dev lcms-dev cmake make g++ msttcorefonts-installer fontconfig && \
  git clone --branch v2.3.0 --single-branch --depth 1 https://github.com/uclouvain/openjpeg.git && \
  mkdir /tmp/openjpeg/build && \
  cd /tmp/openjpeg/build && \
  cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr && \
  make install && \
  update-ms-fonts && \
  fc-cache -f && \
  rm -rf /tmp/openjpeg && \
  apk del git make cmake g++ ruby openssl

RUN apk add --update --no-cache curl && \
  curl -o /usr/local/cantaloupe.zip -L "https://github.com/medusa-project/cantaloupe/releases/download/v$VERSION/cantaloupe-$VERSION.zip" && \
  unzip /usr/local/cantaloupe.zip -d /usr/local && \
  rm -rf /usr/local/cantaloupe.zip && \
  mkdir -p /var/log/cantaloupe && \
  mkdir -p /var/cache/cantaloupe && \
  mkdir -p /etc/cantaloupe && \  
  chown -R cantaloupe /var/log/cantaloupe /var/cache/cantaloupe /etc/cantaloupe && \
  apk del curl

COPY etc/docker/app/cantaloupe.toml /etc/confd/conf.d/
COPY cantaloupe.properties /etc/confd/templates/

USER cantaloupe
EXPOSE 8182

CMD ["sh", "-c", "/usr/local/bin/confd -onetime -backend env && java -Dcantaloupe.config=/etc/cantaloupe/cantaloupe.properties -Dcom.sun.media.jai.disableMediaLib=true -Xmx4g -jar /usr/local/cantaloupe-$VERSION/cantaloupe-$VERSION.war"]
