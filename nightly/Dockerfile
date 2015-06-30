# Define docker container we want to use as a basis for the new container
FROM tomcat

MAINTAINER http://kieker-monitoring.net/support/

# set working directory (within the container)
WORKDIR /opt


##
# ENV sets a global environment variable within the container
##

# Set kieker environment variables
ENV KIEKER_VERSION 1.12-20150630.003920-82
ENV KIEKER_FOLDER /opt/kieker
ENV KIEKER_AGENT ${KIEKER_FOLDER}/agent
ENV KIEKER_CONFIG ${KIEKER_FOLDER}/config
ENV KIEKER_LOGS ${KIEKER_FOLDER}/logs
ENV KIEKER_WEBAPPS ${KIEKER_FOLDER}/webapps
ENV KIEKER_JPETSTORE ${KIEKER_WEBAPPS}/jpetstore

# File name definitions (to be able to change them easily later on)
ENV KIEKER_MONITORING_PROPERTIES kieker.monitoring.properties
ENV KIEKER_AGENT_JAR kieker-${KIEKER_VERSION}-aspectj.jar
ENV KIEKER_AGENT_BASE_URL "https://oss.sonatype.org/content/groups/staging/net/kieker-monitoring/kieker/1.12-SNAPSHOT"
ENV KIEKER_TOMCAT_METAINF /usr/local/tomcat/lib/META-INF
ENV KIEKER_TOMCAT_WEBAPPS /usr/local/tomcat/webapps
ENV KIEKER_JPETSTORE_FOLDER jpetstore


##
# COPY copies a file from the host to the container
##

# Copy files to container
COPY ${KIEKER_MONITORING_PROPERTIES} ${KIEKER_CONFIG}/${KIEKER_MONITORING_PROPERTIES}
COPY ${KIEKER_JPETSTORE_FOLDER} ${KIEKER_JPETSTORE}

##
# RUN executes a command on the container
# (it is advised to concatenate the commands to reduce the number of intermittent containers during the build)
##

# Create needed folders and download JAR
RUN \
mkdir -p ${KIEKER_AGENT} && \
mkdir -p ${KIEKER_LOGS} && \
mkdir -p ${KIEKER_TOMCAT_METAINF} && \
wget ${KIEKER_AGENT_BASE_URL}/${KIEKER_AGENT_JAR} -O ${KIEKER_AGENT}/${KIEKER_AGENT_JAR} && \
#
# Create symlinks to the AspectJ configuration file
ln -s ${KIEKER_JPETSTORE} ${KIEKER_TOMCAT_WEBAPPS}/${KIEKER_JPETSTORE_FOLDER} && \
ln -s ${KIEKER_WEBAPPS}/${KIEKER_LIVEDEMO_WAR} ${KIEKER_TOMCAT_WEBAPPS}/${KIEKER_LIVEDEMO_WAR} && \
#
# Insert the JavaVM arguments for instrumentation into catalina.sh
sed -i '250i\'"export KIEKER_JAVA_OPTS=\" \
-javaagent:${KIEKER_AGENT}/${KIEKER_AGENT_JAR} \
-Dkieker.monitoring.configuration=${KIEKER_CONFIG}/${KIEKER_MONITORING_PROPERTIES} \
-Dkieker.monitoring.writer.filesystem.AsyncFsWriter.customStoragePath=${KIEKER_LOGS} \
-Daj.weaving.verbose=true \
-Dkieker.monitoring.skipDefaultAOPConfiguration=true \
\"" /usr/local/tomcat/bin/catalina.sh && \
sed -i '251i\'"export JAVA_OPTS=\"\${KIEKER_JAVA_OPTS} \${JAVA_OPTS}\"" /usr/local/tomcat/bin/catalina.sh

VOLUME ["/opt/kieker"]

##
# CMD defines a default command that is executed when no command is given
##

# Here we just start the tomcat server
CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]

##
# EXPOSE exposes the given port from the container
##

# Expose the tomcat default port
EXPOSE 8080
