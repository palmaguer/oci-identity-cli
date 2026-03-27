# Groups API Documentation

The **Groups API** enables you to manage groups in Oracle Identity Cloud, including searching, creating, updating, deleting, and managing group memberships.

---

## Features

- **Search Groups**: Query groups using filters, pagination, and sorting.
- **Create Group**: Create new groups with specified attributes and optional members.
- **Update Group**: Modify group details or members using SCIM-compliant PATCH operations.
- **Delete Group**: Remove a group by its unique identifier.
- **Manage Group Members**: Add or remove members from a group.
- **Retrieve Group Members**: Fetch the list of all members in a specific group.

---

## Methods

### 1. Search Groups

Query groups with advanced filtering, pagination, and sorting.

**Signature:**
```javascript
async search(queryParams = {})
```

- `filter` (optional): SCIM filter (e.g., `displayName eq 'Developers'`)
- `attributes` (optional): CSV list of attributes to return.
- `count` (optional): Max results per page (default 100, max 1000).
- `sortBy` (optional): Attribute to sort by.
- `sortOrder` (optional): `ascending` or `descending`.
- `startIndex` (optional): Offset for pagination.

**Example:**
```javascript
const groups = await groupsApi.search({
  filter: "displayName eq 'Developers'",
  attributes: "id,displayName",
  count: 100,
  sortBy: "displayName",
  sortOrder: "ascending"
});
```

---

### 2. Create Group

Create a new group.

**Signature:**
```javascript
async createGroup(groupData)
```

- `groupData`: Object containing group details. `displayName` is required.

**Example:**
```javascript
const newGroup = await groupsApi.createGroup({
  schemas: ["urn:ietf:params:scim:schemas:core:2.0:Group"],
  displayName: "New Group",
  members: [{ value: "userId1", type: "User" }]
});
```

---

### 3. Update Group

Update an existing group's attributes or members.

**Signature:**
```javascript
async patchGroup(groupId, payload)
```

- `groupId`: The group's unique ID.
- `payload`: SCIM PATCH payload.

**Example:**
```javascript
await groupsApi.patchGroup("groupId123", {
  schemas: ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
  Operations: [{
    op: "replace",
    path: "displayName",
    value: "Updated Group Name"
  }]
});
```

---

### 4. Delete Group

Delete a group by ID.

**Signature:**
```javascript
async deleteGroup(groupId)
```

**Example:**
```javascript
await groupsApi.deleteGroup("groupId123");
```

---

### 5. Add Group Members

Add one or more members to a group.

**Signature:**
```javascript
async patchGroup(groupId, payload)
```

**Example:**
```javascript
await groupsApi.patchGroup("groupId123", {
  schemas: ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
  Operations: [{
    op: "add",
    path: "members",
    value: [
      { value: "userId1", type: "User" },
      { value: "userId2", type: "User" }
    ]
  }]
});
```

---

### 6. Remove Group Members

Remove one or more members from a group.

**Signature:**
```javascript
async patchGroup(groupId, payload)
```

**Example:**
```javascript
await groupsApi.patchGroup("groupId123", {
  schemas: ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
  Operations: [{
    op: "remove",
    path: "members[value eq 'userId1']"
  }]
});
```

---

### 7. Get Group Members

Retrieve a group's details and member list.

**Signature:**
```javascript
async getGroupById(groupId, queryParams)
```

**Example:**
```javascript
const group = await groupsApi.getGroupById("groupId123", { attributes: "members,displayName" });
console.log(group.members);
```

---

### SCIM Filter Examples

Sample SCIM filters for querying groups:

- `displayName eq 'Developers'` - Exact name match
- `displayName co 'Admin'`      - Name contains "Admin"
- `id eq '0123456789'`          - Find by specific group ID

Refer to the [SCIM specification](./SCIM.md) for more options.

---

Certainly! Here’s an extension of your Groups API documentation with practical Bash CLI usage examples (assuming your CLI tool provides group management commands like `group-search`, `group-create`, etc., similar to your `oci-identity` usage):

---

## Bash Usage Examples

All commands require the path to your environment variables file via `--envfile` for authentication.

### 1. Search Groups

Search by group display name:

```bash
oci-identity group-search --envfile ./path/to/envfile.env --filter "displayName eq 'Developers'"
```

Search by partial display name (groups containing "Admin"):

```bash
oci-identity group-search --envfile ./path/to/envfile.env --filter "displayName co 'Admin'"
```

Pagination and sorting:

```bash
oci-identity group-search --envfile ./path/to/envfile.env --count 50 --sortBy displayName --sortOrder ascending
```

---

### 2. Create Group

Create a group called "New Group":

```bash
oci-identity group-create --envfile ./path/to/envfile.env --displayName "New Group"
```

Create a group with initial members (space-separated user IDs):

```bash
oci-identity group-create --envfile ./path/to/envfile.env --displayName "Engineering" --members userId1 userId2
```

---

### 3. Update Group

Rename a group:

```bash
oci-identity group-update --envfile ./path/to/envfile.env --groupId <group_id> --displayName "Updated Group Name"
```

---

### 4. Delete Group

Delete a group by ID:

```bash
oci-identity group-delete --envfile ./path/to/envfile.env --groupId <group_id>
```

---

### 5. Add Group Members

Add multiple members to a group:

```bash
oci-identity group-add-members --envfile ./path/to/envfile.env --groupId <group_id> --members userId1 userId2
```

---

### 6. Remove Group Members

Remove a member from a group:

```bash
oci-identity group-remove-members --envfile ./path/to/envfile.env --groupId <group_id> --members userId1
```

---

### 7. Retrieve Group Members

Get all members of a group:

```bash
oci-identity group-get --envfile ./path/to/envfile.env --groupId <group_id> --attributes members,displayName
```

---

### General Notes

- Replace `<group_id>`, `userId1`, and `userId2` with actual group and user identifiers.
- For more options and details, run:
  ```bash
  oci-identity --help
  oci-identity group-<command> --help
  ```

---

This section demonstrates how to use the CLI tool for group management tasks directly from your terminal or in automation scripts. Adjust flag and option names as needed to match your CLI’s actual implementation.


---

## Release Notes

This release supports:

- Flexible group search with filtering, sorting, and pagination
- Group creation, update, and deletion
- Group membership management
- Attribute selection for optimized results

**Example Use Cases:**

- Create a new group and add members at creation.
- Search for groups using sophisticated SCIM filters.
- Update group details or batch manage group members.
- Delete unused groups.

---

For further details, consult the official API references or the [SCIM specification](./SCIM.md).