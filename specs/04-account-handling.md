# Himalaya-Vim Account Handling Analysis

## How Default Account Works

### Account Discovery
```bash
himalaya account list --output json
```

Returns:
```json
[
  {"name":"main","backend":"IMAP, SMTP","default":true},
  {"name":"pro","backend":"IMAP, SMTP","default":false}
]
```

The account with `"default": true` is the default account.

### Implementation in himalaya-vim

1. **No automatic initialization**: Account is stored as empty string initially
   ```vim
   let s:account = ''
   ```

2. **Lazy loading**: Account is only set when:
   - User explicitly calls `:HimalayaAccounts` to pick an account
   - User calls `:Himalaya <account_name>` with account argument
   - Account is set via `himalaya#domain#account#set(account)`

3. **Account selection flow**:
   ```
   :Himalaya
   └─> himalaya#domain#email#list()
       └─> account = himalaya#domain#account#current()  # Returns empty string if not set
           └─> Uses empty account (himalaya CLI uses default)
   ```

4. **CLI behavior**: When account is empty string, himalaya CLI automatically uses the default account

5. **Command structure**:
   ```vim
   himalaya --output json account list
   himalaya --output plain envelope list --folder INBOX --account "" --page 1
   ```

## Key Insights

1. **No explicit default account fetching**: himalaya-vim relies on the CLI's default account behavior
2. **Empty string = default**: Passing empty string to `--account` makes CLI use default
3. **Account state**: Stored in script-local variable `s:account`
4. **INBOX default**: When account is set, folder defaults to "INBOX"

## Recommendation for himalaya.nvim

**Option 1: Follow himalaya-vim approach**
- Start with empty account
- Let CLI handle default
- Simple and reliable

**Option 2: Fetch default explicitly**
- Call `himalaya account list --output json`
- Parse and find `"default": true`
- Store in state
- More explicit but adds complexity

**Recommended: Option 1** - Keep it simple, let the CLI handle defaults.
