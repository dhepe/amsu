FROM ubuntu:20.04

LABEL version="1"
LABEL description="This is custom Docker Image for the Tomcat 7 with SSL, OpenJDK7 and Amatra Support"

ARG DEBIAN_FRONTEND=noninteractive

RUN echo "===> update dan upgrade ubuntu repository" && \
    apt-get -y update && apt-get -y upgrade

RUN echo "===> install wget dan openjdk untuk keytool" && \
    apt-get -y install wget openjdk-8-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "===> create folder java-se-7u75-ri dan tomcat7 di /opt" && \
    mkdir /opt/java-se-7u75-ri && \
    mkdir /opt/tomcat7

RUN echo "===> download openjdk7 dan install openjdk7" && \
    wget https://download.java.net/openjdk/jdk7u75/ri/openjdk-7u75-b13-linux-x64-18_dec_2014.tar.gz -O /tmp/openjdk-7u75-b13-linux-x64-18_dec_2014.tar.gz && \
    cd /tmp && tar xvfz openjdk-7u75-b13-linux-x64-18_dec_2014.tar.gz && \
    cp -Rv /tmp/java-se-7u75-ri/* /opt/java-se-7u75-ri

RUN echo "===> download tomcat7 dan install tomcat7" && \
    wget https://downloads.apache.org/tomcat/tomcat-7/v7.0.105/bin/apache-tomcat-7.0.105.tar.gz -O /tmp/tomcat.tar.gz && \
    cd /tmp && tar xvfz tomcat.tar.gz && \
    cp -Rv /tmp/apache-tomcat-7.0.105/* /opt/tomcat7

ENV JAVA_HOME /opt/java-se-7u75-ri
ENV JRE_HOME /opt/java-se-7u75-ri
ENV CATALINA_HOME /opt/tomcat7
ENV PATH $PATH:$JAVA_HOME/bin

RUN echo "===> set tomcat7 environment" && \
    echo 'export JAVA_OPTS="-Dfile.encoding=UTF-8 -Xms2048m -Xmx2048m -XX:PermSize=1024m -XX:MaxPermSize=1024m"' >> /opt/tomcat7/bin/setenv.sh

RUN echo "===> download dan install amatra war" && \
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1IjHnlOsOgCxxNUGkGE6XXjpMfGFTBT4Z' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1IjHnlOsOgCxxNUGkGE6XXjpMfGFTBT4Z" -O /opt/tomcat7/webapps/mobilesales.war && rm -rf /tmp/cookies.txt

CMD ["/opt/tomcat7/bin/startup.sh"]

RUN echo "===> download certificate" && \
    wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1auGEzHg4kIpo3xM2MUhi6RDOL0UPq6jb' -O /opt/tomcat7/conf/fullchain.pem && \
    wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1gKOcgzu05zZKUZqbaiT9MtDWX9SHeEFv' -O /opt/tomcat7/conf/privkey.pem

RUN echo "===> create p12 file" && \
    cd /opt/tomcat7/conf && \
    openssl pkcs12 -export -in fullchain.pem -inkey privkey.pem -out compnet.p12 -name tomcat -password pass:c0mpn3t

RUN echo "===> create jks file" && \
    keytool -importkeystore -deststorepass c0mpn3t -destkeypass c0mpn3t -destkeystore compnet.jks -srckeystore compnet.p12 -srcstoretype PKCS12 -srcstorepass c0mpn3t -alias tomcat -noprompt

RUN echo "===> add config ssl" && \
    sed -i '93i <Connector port="8443" protocol="org.apache.coyote.http11.Http11Protocol"\nURIEncoding="UTF-8" maxThreads="150" SSLEnabled="true"\nscheme="https" secure="true" clientAuth="false" sslProtocol="TLS"\nkeystoreFile="/opt/tomcat7/conf/compnet.jks" keystorePass="c0mpn3t"\nkeyAlias="tomcat" keyPass="c0mpn3t"/>' /opt/tomcat7/conf/server.xml

RUN wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1Xiikf_vIjy2o4DJ85MwMOekKtQ1vng4y' -O /opt/tomcat7/conf/mobilesales-config.properties

CMD ["/opt/tomcat7/bin/shutdown.sh"]

RUN  update-alternatives --install "/usr/bin/java" "java" "/opt/java-se-7u75-ri/bin/java" 1
RUN  update-alternatives --install "/usr/bin/javac" "javac" "/opt/java-se-7u75-ri/bin/javac" 1
RUN  update-alternatives --set java /opt/java-se-7u75-ri/bin/java
RUN  update-alternatives --set javac /opt/java-se-7u75-ri/bin/javac

RUN java -version
RUN javac -version

VOLUME ["/opt/tomcat7/bin", "/opt/tomcat7/conf", "/opt/tomcat7/webapps"]

EXPOSE 8080 8443
CMD ["/opt/tomcat7/bin/catalina.sh", "run"]
