#!/bin/bash

# Check if the environment file argument is provided
if [ -z "$1" ]; then
  echo "============================================================="
  echo "Usage: $0 <envfile> [filter]"
  echo ""
  echo "Examples:"
  echo "  $0 /path/to/env/file"
  echo "  $0 /path/to/env/file \"displayName sw \\\"CLI\\\"\""
  echo "  $0 /path/to/env/file \"id eq \\\"01201289301\\\"\""
  echo ""
  echo ""
  exit 1
fi

# Set the environment file path from the first argument
ENVFILE="$1"

# Set the filter expression from the second argument, if provided
FILTER="${2:-}"

# Define the group-search command with an optional filter
if [ -n "$FILTER" ]; then
  echo "Searching for groups with filter: $FILTER"
  SEARCH_CMD="oci-identity group-search -e \"$ENVFILE\" --filter '$FILTER'"
else
  echo "Searching for all groups"
  SEARCH_CMD="oci-identity group-search -e \"$ENVFILE\""
fi

echo $SEARCH_CMD

# Run the search command and capture any errors
SEARCH_RESPONSE=$(eval $SEARCH_CMD 2>&1)

# Check if the request failed (e.g., HTTP 400 or 500 error)
if echo "$SEARCH_RESPONSE" | grep -q "Request failed with status code"; then
  echo "Error: Failed to search groups."
  echo "$SEARCH_RESPONSE"
  exit 1
fi

# Get the totalResults value from the JSON response
GROUP_COUNT=$(echo "$SEARCH_RESPONSE" | jq '.totalResults')

# If GROUP_COUNT is not a valid number, handle it gracefully
if [ -z "$GROUP_COUNT" ] || ! [[ "$GROUP_COUNT" =~ ^[0-9]+$ ]]; then
  echo "Error: Failed to retrieve group count or no valid groups found."
  exit 1
fi

# If no groups are found, exit the script
if [ "$GROUP_COUNT" -eq 0 ]; then
  echo "No groups found to delete."
  exit 0
fi

# Extract the group IDs and display names from the response
GROUPS_OUTPUT=$(echo "$SEARCH_RESPONSE" | jq -r '.Resources[] | "\(.id) \(.displayName)"')

# Display the groups to be deleted
echo "The following groups will be deleted:"
echo "$GROUPS_OUTPUT"

# Ask for confirmation before proceeding
read -p "Are you sure you want to delete these $GROUP_COUNT group(s)? (yes/no) " CONFIRM

# Check the user's response
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborting deletion."
  exit 1
fi

# Loop through each group and delete it
echo "$GROUPS_OUTPUT" | while read -r id displayName; do
  echo "Deleting group: $displayName (ID: $id)"
  
  # Call the group-delete command for each group ID
  

    # Call the user-delete command for each user ID
  DELETE_RESPONSE=$(oci-identity group-delete -e "$ENVFILE" "$id" 2>&1)

  # Check if the delete response is a success (status 204)
  if echo "$DELETE_RESPONSE" | grep -q "success"; then
    echo "Group $displayName (ID: $id) deleted successfully."
  else
    echo "Failed to delete group $displayName (ID: $id)."
    echo "$DELETE_RESPONSE"
  fi

  
done

echo "Deletion complete."
