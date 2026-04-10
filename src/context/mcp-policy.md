# MCP & External Integration Policy

## Allowed by Default
- Read, Edit, Write inside approved workspaces
- lint, test, build commands
- approved plugins from managed marketplace

## Requires Human Approval
- deployment to production
- customer-facing email/message send
- scheduled tasks with external side effects
- database writes to production
- new MCP server connection

## Blocked
- reading `.env*` files
- destructive shell commands
- unapproved MCP servers
- editing outside approved repositories

## MCP Evaluation Checklist
Must verify before connecting a new MCP:
- [ ] Source verification (official / community / individual)
- [ ] Required permission scope (read-only vs read-write)
- [ ] Maintenance status (date of last update)
- [ ] Context cost (are tool descriptions always loaded, or invoked only on demand?)
- [ ] Conflict with organizational policies

## Connection Principles
- Before asking "what else can we add," ask "which manual step does this connection eliminate?"
- MCP is the layer that opens the path; Skills are the layer that defines how to use that path
- More connections is not better — maintain only what does not weigh down the session

## Connector vs MCP Distinction
- Connector: the surface where users connect services via a settings UI (like connecting a service from an app marketplace)
- MCP: the layer where developers/power users design the server/tool interface (like designing the internal wiring panel for a company)
- "MCP standard" does not mean "any server can be connected without review"
- Check the source, permission scope, and maintenance status first, then gradually add only frequently used connections

## MCP Allowlist Template
Approved MCPs for this project (populate during initialization session):
- {{APPROVED_MCP_1}} — {{MCP_1_PURPOSE}}
- {{APPROVED_MCP_2}} — {{MCP_2_PURPOSE}}
