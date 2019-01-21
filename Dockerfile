FROM ubuntu:14.04.5

# Set druid and zookeeper version which you want to build from
ENV DRUID_VERSION 0.12.3
ENV ZOOKEEPER_VERSION 3.4.6

# vim and curl
RUN  sudo apt-get update \
      && sudo apt-get install -y vim \
      && sudo apt-get install -y curl

# Java 8
RUN apt-get update \
      && apt-get install -y software-properties-common \
      && apt-add-repository -y ppa:webupd8team/java \
      && apt-get purge --auto-remove -y software-properties-common \
      && apt-get update \
      && echo oracle-java-8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
      && apt-get install -y oracle-java8-installer oracle-java8-set-default \
                            mysql-server \
                            supervisor \
                            git \
      && apt-get clean \
      && rm -rf /var/cache/oracle-jdk8-installer \
      && rm -rf /var/lib/apt/lists/*

# Druid system user
RUN adduser --system --group --no-create-home druid \
      && mkdir -p /home/users/druid \
      && mkdir -p /var/log/druid \
      && chown -R druid:druid /home/users/druid \
      && chown -R druid:druid /var/log/druid

# Druid tarball
RUN wget -q -O - http://static.druid.io/artifacts/releases/druid-$DRUID_VERSION-bin.tar.gz | tar -xzf - -C /home/users/druid

# Druid examples
RUN wget -q -O - http://druid.io/docs/$DRUID_VERSION/tutorials/tutorial-examples.tar.gz | tar -xzf - -C /home/users/druid/druid-$DRUID_VERSION

# Druid mysql-metadata-storage extension
#RUN wget -q -O - http://static.druid.io/artifacts/releases/mysql-metadata-storage-$DRUID_VERSION.tar.gz | tar -xzf - -C /home/users/druid/druid-$DRUID_VERSION/extensions/

# Zookeeper
RUN wget -q -O - https://archive.apache.org/dist/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xzf - -C /home/users/druid \
      && cp /home/users/druid/zookeeper-$ZOOKEEPER_VERSION/conf/zoo_sample.cfg /home/users/druid/zookeeper-$ZOOKEEPER_VERSION/conf/zoo.cfg \
      && ln -s /home/users/druid/zookeeper-$ZOOKEEPER_VERSION /home/users/druid/zookeeper

WORKDIR /home/users/druid/druid-$DRUID_VERSION

# Make directory for scripts
RUN mkdir scripts

# Replacing properties with custom properties
ADD conf/common.runtime.properties conf/druid/_common/common.runtime.properties
ADD conf/broker.runtime.properties conf/druid/broker/runtime.properties
ADD conf/coordinator.runtime.properties conf/druid/coordinator/runtime.properties
ADD conf/historical.runtime.properties conf/druid/historical/runtime.properties
ADD conf/middleManager.runtime.properties conf/druid/middleManager/runtime.properties
ADD conf/overlord.runtime.properties conf/druid/overlord/runtime.properties
ADD scripts/load_datasources.sh scripts/load_datasources.sh

RUN bin/init
RUN chown -R druid:druid /home/users/druid
RUN chmod +x /home/users/druid/druid-$DRUID_VERSION/scripts/load_datasources.sh

# Setup supervisord
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# - 8081: HTTP (coordinator)
# - 8082: HTTP (broker)
# - 8083: HTTP (historical)
# - 8090: HTTP (overlord)
# - 3306: MySQL
# - 2181 2888 3888: ZooKeeper
# - 9001: HTTP (supervisor)
EXPOSE 8081
EXPOSE 8082
EXPOSE 8083
EXPOSE 8090
EXPOSE 3306
EXPOSE 2181 2888 3888
EXPOSE 9001

WORKDIR /home/users/druid/druid-$DRUID_VERSION
ENTRYPOINT export DRUID_V=$DRUID_VERSION && exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf