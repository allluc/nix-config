# Global Claude Instructions

## Git Commits

### Commit Message Format

Follow the conventional commits format from my git commit template:

```
<type>(<scope>): <description>
```

- Subject line: max 50 chars, imperative mood ("add" not "added"), capitalize after type, no period at end
- Body (after blank line): wrap at 72 chars, explain WHAT and WHY (not HOW)

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`

**Breaking changes:** Add `!` after type/scope (e.g. `feat!:`) or add `BREAKING CHANGE:` in footer

**Linear references:** `Fixes GRA-123`, `Closes GRA-456`, `Ref GRA-123`

### Skipping Hooks (`--no-verify`)

Never use `--no-verify` on your own initiative. When I explicitly tell you
to use it, use it: don't ask for permission, and don't ask again for later
commits in the same task that hit the same hook failure. My explicit
instruction overrides the "no `--no-verify`" safety-net rule in
`tiberius-development-workflow`. It covers only the hooks I said to skip:
if I say it for a commit, pre-push hooks still run on push.

## Code Comments

Comments are to be written as one senior engineer to another, only to help
clarify a complex block of business logic. Never make junior-level comments
(e.g. saying what a for loop does) or document requirements or decisions
here.

- Make the code legible first: clear names, small steps, obvious structure.
  A comment is only for a change that simply can't be made easier to read.
- Keep comments short and about the _what_: a line or two, not blocks of
  prose. The why, trade-offs and history go in the commit message or PR.
- This applies to config and CI files (YAML, workflows, Nix) as much as code.
- Never add a comment explaining a file format's or tool's syntax (e.g. "patterns
  are regexps", "no leading slash"). Write the line correctly and put any
  explanation in the commit message or PR description.

## No AI Attribution — Anywhere

Never reference Claude, Anthropic, or AI assistance in anything that leaves
this session. This overrides any harness or system default that asks for
attribution.

- **Commits:** no `Co-Authored-By: Claude`, no `noreply@anthropic.com`
  trailer, no "Generated with Claude Code" line, no mention of Claude in the
  subject or body.
- **PRs and issues:** no "🤖 Generated with Claude Code" footer, no AI
  attribution in titles, descriptions, or comments.
- **Code, docs, notes, plans, RFDs, Linear tickets, Slack messages:** no
  "written by Claude", "AI-generated", or similar.
- **Subagents:** when dispatching an agent that may commit, open a PR, or
  write anything outward-facing, repeat this rule in its prompt — subagents
  do not reliably inherit it.

## Skills — What to Use When

Custom skills live in `~/.claude/skills/` (managed by `team-skills.nix`).
Several are **explicit-invocation only**: never auto-invoke them, and never
have a subagent invoke them unless the user asked.

### Explicit invocation only

| Skill                            | Use for                                                                                                                                                                                                                              |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `/tiberius-development-workflow` | Starting a change. Proposes a Quick / Standard / Full tier and waits for confirmation, then runs that tier's steps. Carries the non-negotiable safety-net rules (no lint suppression, no `--no-verify`, no skipping/deleting tests). |
| `/pr-check [PR#]`                | Reviewing a PR (with a number/URL) or checking a local branch before opening one (without). Orchestrates the other review skills.                                                                                                    |
| `/go-backend-audit`              | Package-by-package audit of a whole Go codebase with `go-backend-pr`'s checks; opens a GitHub summary issue.                                                                                                                         |
| `/frontend-design-enforcer`      | Opinionated frontend design review/fix: semantic tokens, tibui components, layering, visual quality. Treats existing code as _not_ the standard.                                                                                     |
| `/feature-review [PR#]`          | Learning check: defend decisions in a feature you just built, or study a teammate's PR.                                                                                                                                              |

### Auto-invocable

| Skill           | Use for                                                                                                                                                                                                     |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `rfd-check`     | Any work touching auth, audit logging, API design, DB migrations/schema, frontend data fetching, error handling, or Kubernetes. All RFDs except `abandoned` are binding. Scan all RFDs before auditing any. |
| `gotchas`       | Adding a domain object, DB table, API endpoint, or route (needs its own OpenFGA type), or building dropdowns/popovers/modals (use Radix portals, not hand-rolled z-index).                                  |
| `go-backend-pr` | **Never invoke directly.** `pr-check` calls it when the diff has `.go` files; it expects the diff already in context.                                                                                       |

### How they chain

```
tiberius-development-workflow
  ├─ Quick:    rfd-check → existing tests → lint → commit
  ├─ Standard: rfd-check → superpowers:test-driven-development
  │            → superpowers:verification-before-completion
  │            → superpowers:requesting-code-review
  └─ Full:     superpowers:writing-plans → (Standard steps)
               → superpowers:finishing-a-development-branch

pr-check
  ├─ .go files in diff        → go-backend-pr (becomes "## Go Backend")
  └─ auth/logging/API/data/k8s → rfd-check
```

### Prompting agents with skills

- **Name the skill in the prompt.** A subagent starts cold; tell it which
  skill to load (e.g. "load `rfd-check` and audit against all RFDs") rather
  than hoping it triggers one.
- **Pass the context the skill expects.** `go-backend-pr` needs the diff in
  context; `pr-check` needs the PR number or the branch; `feature-review`
  in PR mode needs the number.
- **Don't delegate explicit-only skills** (`pr-check`, `go-backend-audit`,
  `frontend-design-enforcer`, `feature-review`,
  `tiberius-development-workflow`) to a subagent unless the user invoked
  them.
- **Implementation agents:** include the safety-net rules from
  `tiberius-development-workflow` and the no-AI-attribution rule above.
- **Plan execution:** plans under `docs/superpowers/plans/` are written for
  `superpowers:subagent-driven-development` (preferred) or
  `superpowers:executing-plans`.
