#!/bin/bash

set -e

# wait for cluster setup
echo "Waiting for cluster setup..."
sleep 60
echo "Cluster setup complete"

# load data sources
echo "Loading data sources..."
FILE="examples/wikipedia-index.json"
echo "Loading $FILE data source"
curl -X 'POST' -H 'Content-Type:application/json' -d @$FILE http://localhost:8090/druid/indexer/v1/task
echo
FILE="examples/rollup-index.json"
echo "Loading $FILE data source"
curl -X 'POST' -H 'Content-Type:application/json' -d @$FILE http://localhost:8090/druid/indexer/v1/task
echo

echo "Indexing of datasources started. Will be queryable in some time."