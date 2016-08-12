#!/bin/bash
set -e
# Unit? tests
export PYTEST_ARGS="--disable-warnings --amqp-uri=amqp://${RABBIT_USER:-guest}:${RABBIT_PASSWORD:-guest}@${RABBIT_HOST:-localhost}:${RABBIT_PORT:-5672}/ --rabbit-api-uri=http://${RABBIT_USER:-guest}:${RABBIT_PASSWORD:-guest}@${RABBIT_HOST:-localhost}:${RABBIT_MANAGEMENT_PORT:-15672}"
pytest --cov=orders/orders --cov-append --junitxml xml/junit-orders.xml ${PYTEST_ARGS} orders/test/ 
pytest --cov=gateway/gateway --cov-append --junitxml xml/junit-gateway.xml ${PYTEST_ARGS} gateway/test/
pytest --cov=products/products --cov-append --junitxml xml/junit-products.xml ${PYTEST_ARGS} products/test/
coverage report -m
coverage xml -o xml/coverage.xml
coverage html -d html --fail-under 80
