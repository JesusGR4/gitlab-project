#!/bin/bash
set -ex

# Smoke test
export SERVICE_URL=gateway:8000
pytest --junitxml=xml/smoke.xml test/smoke/test_smoke.tavern.yaml
