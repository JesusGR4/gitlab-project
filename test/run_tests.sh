#!/bin/bash
set -ex

echo 'Unit tests'
./run_unittest.sh

echo 'Smoke test'
./run_smoketest.sh
