#!/bin/sh
set -e

# stream output
export PYTHONUNBUFFERED=1
# show ANSI-colored output
export ANSIBLE_FORCE_COLOR=true

TARGET_HOSTS="${TARGET_HOSTS:-remote}"

ansible-playbook \
    -i inventory.yaml \
    -i ../private/ansible/inventory.yaml \
    ./playbook.yml \
    --extra-vars "variable_host=$TARGET_HOSTS" \
    --ask-become-pass

