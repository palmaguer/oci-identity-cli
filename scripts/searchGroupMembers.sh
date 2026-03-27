#!/usr/bin/bash


# Check if the environment file argument is provided - TODO: Edit this function for this new script.
if [ -z "$1" ]; then
  echo "============================================================="
  echo "Usage: $0 <envfile> [group name]"
  echo ""
  echo "Examples:"
  echo "  $0 /path/to/env/file"
  echo "  $0 /path/to/env/file \"userName sw \\\"john\\\"\""
  echo "  $0 /path/to/env/file \"id eq \\\"0123456789\\\"\""
  echo ""
  echo ""
  exit 1
fi

# Set the environment file path from the first argument
ENVFILE="$1"

# Set the filter expression from the second argument, if provided
FILTER="${2:-}"

# Define the user-search command with an optional filter
if [ -n "$FILTER" ]; then
  echo "Searching for users with filter: $FILTER"
  SEARCH_CMD="oci-identity user-search -e \"$ENVFILE\" --filter '$FILTER'"
else
  echo "Searching for all users"
  SEARCH_CMD="oci-identity user-search -e \"$ENVFILE\""
fi


function _getGroupId() {
  let

  oci-gs --filter "displayName sw 'ORCV_' and not (displayName co '_PREPROD')" --attributes "id,displayName" --sortBy displayName \
  > data/anf_orcv_jobroles.json # Optional line to saved the command output.

}