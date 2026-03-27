#!/bin/bash
shopt -s expand_aliases

# Declare this variable in your script.
ENV_FILE=""

# Create an alias of commands to make it faster to type
alias oci-gs='oci-identity group-search -e ${ENV_FILE}'
alias oci-gam='oci-identity group-add-members -e ${ENV_FILE}'
alias oci-grm='oci-identity group-remove-members -e ${ENV_FILE}'
alias oci-us='oci-identity user-search -e ${ENV_FILE}'
alias oci-uc='oci-identity user-create -e ${ENV_FILE}'
