#!/bin/bash

component=$1    #frontend
environment=$2  #dev
echo "Component: $component, Environment: $environment"
dnf install ansible -y
ansible-pull -i localhost, -U https://github.com/raghuatharva/expense-ansible-roles-tf.git main.yaml -e component=$component -e environment=$environment