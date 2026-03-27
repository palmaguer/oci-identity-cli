#!/bin/bash

payload=$1
jq '.Resources[] | { displayName: .displayName, userName: .userName, email: .emails[0].value, id: .id }' <<< "$payload"