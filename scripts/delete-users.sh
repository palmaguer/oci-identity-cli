#!/bin/bash

# Check if the environment file argument is provided
if [ -z "$1" ]; then
  echo "============================================================="
  echo "Usage: $0 <envfile> [filter]"
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

# Run the search command and capture any errors
SEARCH_RESPONSE=$(eval $SEARCH_CMD 2>&1)

# Check if the request failed (e.g., HTTP 400 or 500 error)
if echo "$SEARCH_RESPONSE" | grep -q "Request failed with status code"; then
  echo "Error: Failed to search users."
  echo "$SEARCH_RESPONSE"
  exit 1
fi

# Get the totalResults value from the JSON response
USER_COUNT=$(echo "$SEARCH_RESPONSE" | jq '.totalResults' 2>/dev/null)

# If USER_COUNT is not a valid number, handle it gracefully
if [ -z "$USER_COUNT" ] || ! [[ "$USER_COUNT" =~ ^[0-9]+$ ]]; then
  echo "Error: Failed to retrieve user count or no valid users found."
  exit 1
fi

# If no users are found, exit the script
if [ "$USER_COUNT" -eq 0 ]; then
  echo "No users found to delete."
  exit 0
fi

# Extract the user IDs and display names from the response
USERS_OUTPUT=$(echo "$SEARCH_RESPONSE" | jq -r '.Resources[] | "\(.id) \(.userName)"')

# Display the users to be deleted
echo "The following users will be deleted:"
echo "$USERS_OUTPUT"

# Ask for confirmation before proceeding
read -p "Are you sure you want to delete these $USER_COUNT user(s)? (yes/no) " CONFIRM

# Check the user's response
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborting deletion."
  exit 1
fi

# Loop through each user and delete them
echo "$USERS_OUTPUT" | while read -r id userName; do
  echo "Deleting user: $userName (ID: $id)"
  
  # Call the user-delete command for each user ID
  DELETE_RESPONSE=$(oci-identity user-delete -e "$ENVFILE" "$id" 2>&1)

  # Check if the delete response is a success (status 204)
  if echo "$DELETE_RESPONSE" | grep -q "success"; then
    echo "User $userName (ID: $id) deleted successfully."
  else
    echo "Failed to delete user $userName (ID: $id)."
    echo "$DELETE_RESPONSE"
  fi
done

echo "Deletion complete."
