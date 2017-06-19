#!/bin/bash

set -euo pipefail

cd "$(dirname $0)"

ansible-playbook \
  -i 'localhost,' \
  playbook.yml
