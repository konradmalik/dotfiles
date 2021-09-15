#!/bin/sh

set -e

ansible-galaxy collection install community.general
ansible-galaxy collection install kewlfft.aur
