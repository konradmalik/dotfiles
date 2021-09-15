#!/bin/sh

set -e

# stream output
export PYTHONUNBUFFERED=1
# show ANSI-colored output
export ANSIBLE_FORCE_COLOR=true

ansible-playbook -vv -i "localhost," -c local ./playbook.yml --extra-vars "ansible_become_pass=$1"
