#!/bin/bash

echo "Старт Zookeeper..."
docker-compose up -d zookeeper

echo "Ожидание запуска Zookeeper..."
sleep 10

echo "Initializing Pulsar cluster metadata..."
docker run --rm --net=dop_pulsar \
    apachepulsar/pulsar-all:latest bash -c "bin/pulsar initialize-cluster-metadata \
--cluster cluster-a \
--zookeeper zookeeper:2181 \
--configuration-store zookeeper:2181 \
--web-service-url http://broker:8080 \
--broker-service-url pulsar://broker:6650"

echo "Starting all services..."
docker-compose up -d pulsar-manager

echo "Waiting for Pulsar Manager to be ready..."
sleep 30

echo "Setting up Pulsar Manager superuser..."
CSRF_TOKEN=$(curl -s http://localhost:7750/pulsar-manager/csrf-token)
curl \
   -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
   -H "Cookie: XSRF-TOKEN=$CSRF_TOKEN;" \
   -H "Content-Type: application/json" \
   -X PUT http://localhost:7750/pulsar-manager/users/superuser \
   -d '{"name": "apachepulsar", "password": "apachepulsar", "description": "Super user", "email": "admin@test.org"}'

docker-compose stop

echo "Setup complete!"
echo "Pulsar Manager: http://localhost:9527"
echo "Login: apachepulsar / apachepulsar"
