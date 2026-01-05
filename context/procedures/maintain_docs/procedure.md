# Documentation Maintenance Procedure

## 1. Analyze Changes
Identify the new component (file or folder) that was added.
- **Example:** Added `context/procedures/new_thing/`

## 2. Read README
```bash
read_file README.md
```

## 3. Determine Section
Locate the appropriate subsection in `README.md` for the new item:
- **`context/`**: For top-level context files.
- **`context/installation_bundles/`**: For new software bundles.
- **`context/procedures/`**: For new SOPs.

## 4. Update Content
Use `replace` to insert the new item into the list.

**Format:**
`*   **`<Name>`**: <Brief Description>`

**Example Update:**
```markdown
### `context/procedures/`
*   **`exclude_bundles/`**: ...
*   **`init_change_log/`**: ...
*   **`new_thing/`**: Description of the new thing.
```

## 5. Security Check
Verify that the description does not contain sensitive information (IPs, usernames, passwords). Use generic terms (e.g., "VM" instead of "my-specific-hostname...").
