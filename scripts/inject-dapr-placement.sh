#!/bin/bash
set -o errexit

yq --inplace '.services.placement = {"image": "daprio/dapr", "command": ["./placement", "-port", "50006"], "ports": ["50006:50006"]}' compose.yaml