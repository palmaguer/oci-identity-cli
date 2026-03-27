#!/usr/bin/bash


ENVFILE="/path/to/.env"
DATA_FILE="/path/to/datasheet.csv'"


function check_group {
  local group_name="$1"
  payload=$(oci-identity group-search -e "${ENVFILE}" --filter "displayName eq '${group_name}'")
}

function create_group {
  local group_name="$1"
  local description="$2"
  payload=$(oci-identity group-create -e "${ENVFILE}" --groupName "$role_name" --description "$description")
}


while IFS=',' read -r role_name description; do
  echo "----------------------------------------"                                             
  echo "Role name: \"$role_name\""
  echo "Description: \"$description\""
  echo "----------------------------------------"
  echo ""
done < "$DATA_FILE"
