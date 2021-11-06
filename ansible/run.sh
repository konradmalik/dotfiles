#!/bin/sh
set -e

# stream output
export PYTHONUNBUFFERED=1
# show ANSI-colored output
export ANSIBLE_FORCE_COLOR=true

ansible-playbook \
    -i inventory.yaml \
    -i ../private/ansible/inventory.yaml \
    ./playbook.yml \
    --extra-vars "variable_host=remote" \
    --ask-become-pass
