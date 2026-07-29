---
name: sync-ticket-issue
description: Sync a vault ticket under 08_Roadmap_and_Planning/Tickets/ with a single GitHub issue in JKneedler/questvale — opens the issue once a ticket reaches Next/In Progress, re-pushes content after vault edits, and closes it when status flips to Done. One issue per ticket; subtasks are tracked as a checklist with full detail inside that one issue, not as separate issues. Trigger on "sync this ticket to GitHub", "open the issue for X", "mirror this ticket", or when a ticket's vault content changed since it was last mirrored.
---

# Sync Ticket ↔ Issue

Keeps a vault ticket note and its GitHub mirror consistent. The vault is always the source of truth — this skill pushes vault content *to* GitHub, never the other way.

**One GitHub issue per ticket, no sub-issues.** Every subtask's full detail (User Story, Acceptance Criteria, Out of Scope) lives directly in that one issue's body, under its own heading — not split into separate sub-issues. This keeps the ticket-to-GitHub mapping simple; a coding session works from one issue and reads down to the subtask it's tackling.

**Target repo is always `JKneedler/questvale`** (the Flutter app repo where the coding sessions and PRs happen) — pass `--repo JKneedler/questvale` explicitly on every `gh issue` call, regardless of whether this session's cwd is the vault or the Flutter repo. Never target `questvale-vault` — that repo exists only for syncing this vault itself (e.g. mobile access) and is unrelated to ticket issues.

## Mirroring rule

Only tickets at `status: Next` or later get a GitHub issue. Don't open one for anything still in `Backlog`.

## Sync steps

1. Read the ticket note's frontmatter: `status`, `github_issue`.
2. If `status: Backlog` and `github_issue` is empty — stop and say so; don't create an issue unless the user explicitly overrides.
3. If `status` is `Next`/`In Progress`/`Review` and `github_issue` is empty — **create it**:
   - Build the body from the ticket's actual content: Summary, Design References (resolve each `[[wikilink]]` to plain text — a GitHub issue body can't follow vault links — either the note's title as a plain label, or a one-line inlined fact if it's directly relevant), Out of Scope, and a `## Subtasks` section with **one heading per subtask**, each carrying its own User Story, Acceptance Criteria (as a real checklist), and Out of Scope — i.e. mirror the vault ticket's subtask content in full, just dropping the vault-only `status:`/`github_issue:` bookkeeping lines under each subtask (that state lives in the vault, not GitHub).
   - Write the body to a scratch file, then:
     ```
     gh issue create --repo JKneedler/questvale --title "<area>: <ticket title>" --body-file <scratch-file>
     ```
   - Write the returned issue number into the ticket's `github_issue:` frontmatter field.
4. If `github_issue` is already set — **resync**: rebuild the body the same way and run `gh issue edit <n> --repo JKneedler/questvale --body-file <scratch-file>`.
5. If `status: Done` and the issue is open — `gh issue close <n> --repo JKneedler/questvale`.

## Vault-side bookkeeping

Every time the ticket's `github_issue` number is written or changed, **commit that edit on its own** in the vault repo (e.g. `Link Tasks & Habits ticket to questvale#20`) — this is what makes drift visible instead of silent. Don't bundle it with unrelated vault edits.

## Guardrails

- Never invent issue-body content beyond what's actually written in the vault ticket — if a field is blank, omit it rather than filling in something plausible-sounding.
- Never open an issue for anything still in `Backlog` without an explicit override from the user.
- Never create a sub-issue or otherwise split a ticket's subtasks into separate GitHub issues — one issue per ticket is the whole model now.
- If `gh issue view <n>` shows the issue was manually changed on GitHub in a way that conflicts with the vault (e.g. closed on GitHub but the vault still says `In Progress`), stop and ask which side is correct rather than silently overwriting either one.
- Always pass `--repo JKneedler/questvale` explicitly — never rely on the session's cwd to imply the target repo.
