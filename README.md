# %groups-mcp

MCP server for the channels on a ship's `%groups` desk. `%wicket` is the authorization server. The ship owner decides, per group and per channel, what any token is allowed to touch. A token scope cannot exceed that policy, and the policy cannot exceed what `%channels` lets the ship do.

Endpoint: `{origin}/groups-mcp`. Management page: `{origin}/groups-mcp/manage` (ship `+code`).

| Scope | Tools |
| --- | --- |
| `groups-mcp.channels.list` | `list-channels` |
| `groups-mcp.channels.read` | `read-posts` |
| `groups-mcp.channels.write` | `add-post` |
| `groups-mcp.create` | `create-group`, `create-channel` |

`groups-mcp.channels.write` and `groups-mcp.create` start unchecked on the consent page. That is not the ship-control flag, which is reserved for a scope that can run the ship. Create does not include list, read, or write. A group or chat channel created by a client is opened in ship policy: new groups start at write, and a channel opened in a hidden group leaves that group's other channels hidden. Hide the group or the channel on the management page to take that access away. Groups the owner has not configured are omitted. A channel set to read stays read-only even for a token that has write.

```
zig build -Ddesk=~/Projects/piers/zod/groups-mcp
```

Then `|commit %groups-mcp` and `|install our %groups-mcp`. `%wicket` must already have its origin set. Reload the agent after that if registration is refused.
