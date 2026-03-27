#!/dev/null

# Enable debug logging and call get-token api
LOG_LEVEL=debug node . get-token --file ./src/config/env/external.env
# Call get-token api without debug logging
node . get-token --file ./src/config/env/external.env

# Set some handy env variables for further commands...
ENVFILE="./src/config/env/development.env"
OCI_IDENTITY_URL="https://idcs-xxxx.identity.oraclecloud.com:443"
OCI_OAUTH_CLIENT="xxx"
OCI_OAUTH_SECRET="xxx"
OCI_OAUTH_SCOPE="urn:opc:idm:__myscopes__"

# Call get-token api using OAuth authentication
node . get-token -u "${OCI_IDENTITY_URL}" \
                 -c "${OCI_OAUTH_CLIENT}" \
                 -s "${OCI_OAUTH_SECRET}" \
                 --scope "${OCI_OAUTH_SCOPE}"

node . get-token -u "${OCI_IDENTITY_URL}" -c "${OCI_OAUTH_CLIENT}" -s "${OCI_OAUTH_SECRET}" --scope "${OCI_OAUTH_SCOPE}" | jq

# You can call the get-token api using an env file instead of passing variable through command line
node . get-token --file "${ENVFILE}"
node . list-users --envfile "${ENVFILE}"

# Fetch all users from IDCS starting with "unit_test.". Then, pass payload to jq command to filter out not relevant properties. Then, loop payload, set individual properties in local variables for further usage...
node . user-search --envfile ./src/config/env/external.env --filter 'userName sw "unit_test."' | \
    jq -c '.Resources[] | { id: .id, displayName: .displayName, userName: .userName, email: .emails[0].value, active: .active, locked: .[keys[] | select(test("userState:User$"))].locked.on }' | \
    while read payload; do
      typeset id=$(jq '.id' <<< $payload)
      typeset username=$(jq '.userName' <<< $payload)
      typeset isActive=$(jq '.active' <<< $payload)
      typeset isLocked=$(jq '.locked' <<< $payload)
      
      if [[ "$isActive" == "false" ]]; then
        echo "$payload"
      fi
    done

# read each item in the JSON array to an item in the Bash array
readarray -t my_array < <(
  node . user-search --envfile src/config/env/external.env --filter 'userName sw "unit_test."' | \
      jq --compact-output '.Resources[] | { id: .id, displayName: .displayName, userName: .userName, email: .emails[0].value, active: .active, locked: .[keys[] | select(test("userState:User$"))].locked.on }'
)

# iterate through the Bash array
for item in "${my_array[@]}"; do
  original_name=$(jq --raw-output '.original_name' <<< "$item")
  changed_name=$(jq --raw-output '.changed_name' <<< "$item")
  # do your stuff
done

# Create User using Payload
oci-identity user-create --envfile src/config/env/development.env --payload data/samples/payloads/users-create-example1.json | jq -c '{ id: .id }'
oci-identity user-create --envfile src/config/env/development.env --payload data/samples/payloads/users-create-example2.json | jq -c '{ id: .id }'

# Search for user using filters
oci-identity user-search --envfile src/config/env/development.env --filter 'userName co "doe"' | jq -c '.Resources[] | { id: .id, username: .userName, name: .name.formattedName, email: .emails[0].value }'

# Delete users by userId
oci-identity user-delete --envfile src/config/env/development.env <xxx-xxxxx-xxxxx-xx>
oci-identity user-delete --envfile src/config/env/development.env <xxx-xxxxx-xxxxx-xx>

# Search all Groups
oci-identity group-search --envfile src/config/env/development.env
oci-identity group-search --envfile src/config/env/development.env | jq -c '.Resources[] | { id: .id, displayName: .displayName, created: .meta.created }'

# Search Group using filters
oci-identity group-search --envfile src/config/env/development.env --filter 'displayName sw "CLI"' | jq -c '.Resources[] | { id: .id, displayName: .displayName, created: .meta.created }'

# Create Group using CLI-Arguments without Members:
oci-identity group-create --envfile src/config/env/development.env --groupName "CLI_Test_1" --description "Development team"
# Create Group using CLI-Arguments with a Single Member:
oci-identity group-create --envfile src/config/env/development.env --groupName "CLI_Test_2" --description "Development team" --members "<xxx-xxxxx-xxxxx-xx>"
# Create Group using CLI-Arguments with Multiple Members:
oci-identity group-create --envfile src/config/env/development.env --groupName "CLI_Test_3" --description "Development team" --members '["<xxx-xxxxx-xxxxx-xx>", "<xxx-xxxxx-xxxxx-xx>"]'
# Create Group using Payload without Members:
oci-identity group-create --envfile src/config/env/development.env --payload data/samples/payloads/groups-create-nomembers-example1.json
# Create Group using Payload with Members:
oci-identity group-create --envfile src/config/env/development.env --payload data/samples/payloads/groups-create-members-example1.json

# Delete group using id and environments file
oci-identity group-delete --envfile src/config/env/development.env "<xxx-xxxxx-xxxxx-xx>"
node . group-delete --envfile src/config/env/development.env "<xxx-xxxxx-xxxxx-xx>"
node . group-delete --envfile src/config/env/development.env "<xxx-xxxxx-xxxxx-xx>"
node . group-delete --envfile src/config/env/development.env "<xxx-xxxxx-xxxxx-xx>"
node . group-delete --envfile src/config/env/development.env "<xxx-xxxxx-xxxxx-xx>"