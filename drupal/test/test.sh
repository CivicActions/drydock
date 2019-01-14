#!/usr/bin/env bash
set -euo pipefail

export COMPOSE_FILE=docker-compose.yml
export COMPOSE_PROJECT_NAME=drupal_acquia_${VERSION}_${BRANCH_NAME}

echo "Cleaning up any failed builds"
docker-compose rm -sf
rm -rf docroot

echo "Building containers"
docker-compose build
echo "Downloading Drupal core"
docker run --volume "$(pwd)":/app --user "$(id -u):$(id -g)" drush/drush dl drupal -y --drupal-project-rename=docroot

echo "Starting containers"
docker-compose up --detach
sleep 10

# TODO: Actually install Drupal here and also test dumping and autoloading a database.

echo "Fetching page to check status"
STATUS=$(docker-compose run --rm php curl --location --silent --output /dev/null --write-out "%{http_code}" "http://httpd/")
echo "Status: ${STATUS}"
if [ "${STATUS}" != "200" ]; then
  echo "httpd container not responding with 200 HTTP response code"
  exit 1
fi
echo "Page status OK"

echo "Checking PHP version"
ACTUAL=$(docker-compose run --rm php php --version | head -n 1 | cut -d " " -f 2 | cut -d'.' -f1-2)
if [ "${ACTUAL}" != "${VERSION}" ]; then
  echo "PHP does not match expected version number"
  exit 2
fi
echo "PHP version OK"


echo "Cleaning up"
docker-compose rm -sf
rm -rf docroot
