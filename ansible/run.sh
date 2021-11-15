#!/bin/sh
set -e

# stream output
export PYTHONUNBUFFERED=1
# show ANSI-colored output
export ANSIBLE_FORCE_COLOR=true

# set this to either a host or a group from the inventory
TARGET_HOSTS="${TARGET_HOSTS:-SETME}"

ansible-playbook \
    -i inventory.yaml \
    -i ../private/ansible/inventory.yaml \
    ./playbook.yml \
    --extra-vars "variable_host=$TARGET_HOSTS" \
    --ask-become-pass

