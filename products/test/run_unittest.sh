#!/bin/bash
set -e
# Unit? tests
export PYTEST_ARGS="--disable-warnings --amqp-uri=amqp://${RABBIT_USER:-guest}:${RABBIT_PASSWORD:-guest}@${RABBIT_HOST:-localhost}:${RABBIT_PORT:-5672}/ --rabbit-api-uri=http://${RABBIT_USER:-guest}:${RABBIT_PASSWORD:-guest}@${RABBIT_HOST:-localhost}:${RABBIT_MANAGEMENT_PORT:-15672}"
pytest --cov=${PROJECT}/${PROJECT} --cov-append --junitxml xml/junit-${PROJECT}.xml ${PYTEST_ARGS} ${PROJECT}/test/ 

coverage report -m
coverage xml -o xml/coverage.xml
coverage html -d html --fail-under 80
