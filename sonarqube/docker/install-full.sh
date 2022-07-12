#!/bin/sh

if [ "$(id -u)" -ne 0 ] ; then echo "Please run as root" ; exit 1 ; fi
if [ ! -x "$(command -v docker)" ]; then echo 'docker machine is missing' ; exit 1; fi

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
    depends_on:
      - db
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    ports:
      - "9000:9000"
  db:
    image: postgres:12
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
    volumes:
      - postgresql:/var/lib/postgresql
      - postgresql_data:/var/lib/postgresql/data
volumes:
  sonarqube_data: {}
  sonarqube_extensions: {}
  sonarqube_logs: {}
  postgresql: {}
  postgresql_data: {}
EOF
echo 'done'

echo 'setting vm.max_map_count to 262144 (required by elastic-search)'
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144
echo 'done'

echo 'starting docker-compose.yml...'
docker compose up -d
echo 'done'
