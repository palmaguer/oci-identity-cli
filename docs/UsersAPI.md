Certainly! Here’s an enhanced, comprehensive Users API documentation with clearly structured Bash CLI usage included. This version follows the style of the previously enhanced documentation:

---

# Users API Documentation

The **Users API** provides robust user management for Oracle Identity Cloud. This API lets you search, create, retrieve, and delete user accounts, as well as fetch detailed user information by ID.

---

## Features

- **Search Users:** Filter, paginate, and sort users.
- **Create User:** Add a new user to the system.
- **Retrieve User by ID:** Fetch a user's details via their unique identifier.
- **Delete User:** Remove a user from the system.

---

## Methods

### 1. Search Users

Search for users using various query options such as filtering, pagination, and sorting.

**Signature:**
```javascript
async search(queryParams = {})
```

#### Parameters

- `filter` (optional): SCIM filter string (e.g., `"userName co 'doe'"`)
- `attributes` (optional): Comma-separated attributes to return
- `count` (optional): Max results per page (default 100, max 1000)
- `sortBy` (optional): Attribute to sort by
- `sortOrder` (optional): `ascending` or `descending`
- `startIndex` (optional): Pagination offset

**Example (JavaScript):**
```javascript
const users = await usersApi.search({
  filter: "displayName eq 'John'",
  attributes: "id,displayName",
  count: 100,
  sortBy: "displayName",
  sortOrder: "ascending"
});
```

---

### 2. Get User by ID

Retrieve details for a user by their unique ID.

**Signature:**
```javascript
async getUserById(userId)
```

**Example (JavaScript):**
```javascript
const user = await usersApi.getUserById("userId123");
console.log(user);
```

---

### 3. Create User

Add a new user to Oracle Identity Cloud.

**Signature:**
```javascript
async createUser(data)
```

**Example (JavaScript):**
```javascript
const userData = {
  schemas: ["urn:ietf:params:scim:schemas:core:2.0:User"],
  userName: "johndoe",
  name: { givenName: "John", familyName: "Doe" },
  emails: [{ value: "johndoe@example.com", type: "work", primary: true }],
  active: true
};
const newUser = await usersApi.createUser(userData);
console.log(newUser);
```

---

### 4. Delete User

Remove a user from the system by ID.

**Signature:**
```javascript
async deleteUser(userId)
```

**Example (JavaScript):**
```javascript
await usersApi.deleteUser("userId123");
console.log("User deleted successfully");
```

---

### SCIM Filter Examples

Some filters supported by the **search** method:

- `displayName eq 'John'` — Users with display name "John"
- `userName co 'doe'` — Users whose usernames contain "doe"
- `emails.value eq 'johndoe@example.com'` — Users with specific email
- `meta.lastModified gt '2024-01-01T00:00:00Z'` — Users modified after a certain date

_Refer to the [SCIM specification](./SCIM.md) for more._

---

## Bash Usage Examples

All CLI commands require the `--envfile` flag, pointing to your environment file for authentication.

### Search Users

Search users by display name:
```bash
oci-identity user-search --envfile ./path/to/envfile.env --filter "displayName eq 'John'"
```

Search users whose username contains “doe”:
```bash
oci-identity user-search --envfile ./path/to/envfile.env --filter "userName co 'doe'"
```

Search for a user by email:
```bash
oci-identity user-search --envfile ./path/to/envfile.env --filter "emails.value eq 'johndoe@example.com'"
```

With pagination and sorting:
```bash
oci-identity user-search --envfile ./path/to/envfile.env --count 50 --sortBy displayName --sortOrder ascending
```

---

### Retrieve User by ID

Get details for a user:
```bash
oci-identity user-get --envfile ./path/to/envfile.env --userId userId123
```

Get only specific attributes:
```bash
oci-identity user-get --envfile ./path/to/envfile.env --userId userId123 --attributes id,userName,emails
```

---

### Create User

Create a user with required details:
```bash
oci-identity user-create \
  --envfile ./path/to/envfile.env \
  --userName johndoe \
  --firstName John \
  --lastName Doe \
  --email johndoe@example.com \
  --active true
```

Create a user with additional options (e.g., primary/work email):
```bash
oci-identity user-create \
  --envfile ./path/to/envfile.env \
  --userName janedoe \
  --firstName Jane \
  --lastName Doe \
  --email janedoe@example.com \
  --emailType work \
  --emailPrimary true \
  --active true
```

---

### Delete User

Delete a user by ID:
```bash
oci-identity user-delete --envfile ./path/to/envfile.env --userId userId123
```

---

### Advanced Filtering

Find users modified after a certain date:
```bash
oci-identity user-search --envfile ./path/to/envfile.env --filter "meta.lastModified gt '2024-01-01T00:00:00Z'"
```

---

### Notes

- Replace `userId123`, `johndoe@example.com`, etc., with actual user data.
- For help and more options:
  ```bash
  oci-identity --help
  oci-identity user-<command> --help
  ```
- CLI commands can be used interactively or as part of automation scripts in CI/CD workflows.

---

## Release Notes

This Users API release provides:

- **Advanced User Search:** SCIM filters with pagination and sorting
- **User Creation:** Specify common and custom attributes
- **User Deletion:** Remove users by their unique IDs
- **Selective Querying:** Optimize responses by returning specific attributes

---

**Example Use Cases**

- Create a new user with details like name, email, and active status.
- Efficiently search for users via advanced SCIM filters.
- Retrieve all or some user details by user ID.
- Remove users as part of deprovisioning or automation flows.
