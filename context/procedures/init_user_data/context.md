# User Data Initialization Context

## Goal
To initialize the `context/user_data.json` file if it is missing or incomplete. This file stores personalized or environment-specific information (e.g., IP addresses, usernames) that should not be hardcoded into general procedure documents.

## Triggers
- AI Agent cannot find `context/user_data.json`.
- AI Agent encounters a placeholder (e.g., `{{vm_ip}}`) but the key is missing in the JSON.
- User explicitly asks to update environment details.

## Logic
1.  **Check Existence:** Verify if `context/user_data.json` exists.
2.  **Prompt User:** If missing, ask the user for the required fields.
3.  **Generate File:** Create the JSON file with the provided values.
