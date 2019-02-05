FROM windj007/jupyter-keras-tools

LABEL maintainer="fbrunacci@gmail.com"

RUN apt-get clean && apt-get update

ENV ALMOND_VERSION="0.1.9"
ENV SBT_VERSION="1.2.3"

RUN \
  apt-get update \
  && apt-get install -y curl \
  && apt-get install -y openjdk-8-jdk \
  && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/openjdk-8
ENV PATH=${PATH}:${JAVA_HOME}/bin  

ENV MAVEN_VERSION=3.5.4
RUN wget -q http://www-eu.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    mkdir /opt/maven && \
    tar xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt/maven && \
    rm apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    ln -s /opt/maven/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn

RUN curl -sL --retry 5 "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" \
  | gunzip \
  | tar -x -C "/tmp/" \
  && mv "/tmp/sbt" "/opt/sbt-${SBT_VERSION}" \
  && chmod +x "/opt/sbt-${SBT_VERSION}/bin/sbt"

ENV PATH=${PATH}:/opt/sbt-${SBT_VERSION}/bin/

RUN curl -L -o /usr/local/bin/coursier https://git.io/coursier && chmod +x /usr/local/bin/coursier 

WORKDIR /tmp
ENV ALMOND_VERSION=0.1.9 
ENV SCALA_VERSION=2.12.7
RUN coursier bootstrap \
    -i user -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION \
    sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION \
    -o almond_2_12 && \
    chmod +x almond_2_12 && \
    ./almond_2_12 --id almond_scala_2_12 --display-name "Scala 2.12 (almond)" --install

RUN rm /tmp/almond_2_12

EXPOSE 8888
VOLUME ["/notebook", "/jupyter/certs"]
WORKDIR /notebook

ENV JUPYTER_CONFIG_DIR="/jupyter"

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "jupyter", "notebook", "--ip=0.0.0.0", "--allow-root" ]
