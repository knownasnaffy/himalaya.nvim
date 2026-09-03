local M = {}

M.accounts_json = [[
{
  "accounts": [
    {
      "name": "gmail",
      "default": true,
      "backends": [
        "imap",
        "smtp"
      ]
    },
    {
      "name": "work",
      "default": false,
      "backends": [
        "imap",
        "smtp"
      ]
    }
  ]
}
]]

M.mailboxes_json = [[
{
  "mailboxes": [
    {
      "id": "INBOX",
      "name": "INBOX",
      "total": 42,
      "unread": 3
    },
    {
      "id": "[Gmail]/Drafts",
      "name": "[Gmail]/Drafts",
      "total": 2,
      "unread": 0
    },
    {
      "id": "[Gmail]/Sent Mail",
      "name": "[Gmail]/Sent Mail",
      "total": 150,
      "unread": 0
    }
  ]
}
]]

M.envelopes_json = [[
{
  "envelopes": [
    {
      "id": "14273",
      "message-id": "msg-001@example.com",
      "in-reply-to": [],
      "flags": [
        {
          "iana": "seen",
          "raw": "\\Seen"
        }
      ],
      "subject": "System Alert: All Services Normal",
      "from": [
        {
          "name": "Ops Team",
          "email": "ops@example.com"
        }
      ],
      "to": [
        {
          "name": "User",
          "email": "user@example.com"
        }
      ],
      "date": "2026-09-03T01:10:53Z",
      "size": 8351,
      "has-attachment": false
    },
    {
      "id": "14274",
      "message-id": "msg-002@example.com",
      "in-reply-to": [],
      "flags": [
        {
          "iana": "flagged",
          "raw": "\\Flagged"
        }
      ],
      "subject": "Urgent Review Required",
      "from": [
        {
          "name": null,
          "email": "boss@example.com"
        }
      ],
      "to": [
        {
          "name": null,
          "email": "user@example.com"
        }
      ],
      "date": "2026-09-02T10:00:00Z",
      "size": 2400,
      "has-attachment": true
    }
  ]
}
]]

M.message_read_text = [[
From: ops@example.com
To: user@example.com
Date: Thu, 3 Sep 2026 01:10:53 +0000
Subject: System Alert: All Services Normal

All backend services are operating nominally.
]]

return M
