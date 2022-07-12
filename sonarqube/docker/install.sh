#!/bin/sh

if [ "$(id -u)" -ne 0 ] ; then echo "Please run as root" ; exit 1 ; fi
if [ ! -x "$(command -v docker)" ]; then echo 'docker machine is missing' ; exit 1; fi
if [ -z "$SONAR_JDBC_URL" ] ; then echo "Missing \$SONAR_JDBC_URL variable set" ; exit 1 ; fi
if [ -z "$SONAR_JDBC_USERNAME" ] ; then echo "Missing \$SONAR_JDBC_USERNAME variable set" ; exit 1 ; fi
if [ -z "$SONAR_JDBC_PASSWORD" ] ; then echo "Missing \$SONAR_JDBC_PASSWORD variable set" ; exit 1 ; fi

echo 'setting docker volumes...'
for NAME in "sonarqube_data" "sonarqube_logs" "sonarqube_extensions"; do
  if [ "$(docker volume ls -q -f name="$NAME")" ];
    then
      echo "found volume $NAME.";
    else
      echo "creating volume $NAME...";
#      docker volume create --name "$NAME"
  fi
done;
echo 'done'

echo "(over)write docker compose at $(pwd)/docker-compose.yml... "
cat > docker-compose.yml <<EOF
version: "3.9"
services:
  sonarqube:
    image: sonarqube:lts-community
    environment:
      SONAR_JDBC_URL: $SONAR_JDBC_URL
      SONAR_JDBC_USERNAME: $SONAR_JDBC_USERNAME
      SONAR_JDBC_PASSWORD: $SONAR_JDBC_PASSWORD
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    ports:
      - "9000:9000"
volumes:
  sonarqube_data: {}
  sonarqube_extensions: {}
  sonarqube_logs: {}
EOF
echo 'done'

echo 'setting vm.max_map_count to 262144 (required by elastic-search)'
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144
echo 'done'

echo 'starting docker-compose.yml...'
docker compose up -d
echo 'done'
