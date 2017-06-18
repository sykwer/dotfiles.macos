#!/bin/bash

set -euo pipefail

cd "$(dirname $0)"

ansible-playbook \
  -i 'localhost,' \
  --extra-vars='@config.yml' \
  --extra-vars='@secrets.yml' \
  playbook.yml
