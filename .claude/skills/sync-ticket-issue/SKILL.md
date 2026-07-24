---
name: sync-ticket-issue
description: Sync a vault ticket (or one of its subtasks) under 08_Roadmap_and_Planning/Tickets/ with a GitHub issue/sub-issue in JKneedler/questvale — opens the parent issue once a ticket reaches Next/In Progress, opens a subtask's sub-issue just-in-time when work on it is about to start, re-pushes content after vault edits, and closes issues when status flips to Done. Trigger on "sync this ticket to GitHub", "open the issue for X", "mirror this subtask", when the user is about to start coding a specific subtask and needs its GitHub issue, or when a ticket/subtask's vault content changed since it was last mirrored.
---

# Sync Ticket ↔ Issue

Keeps a vault ticket note and its GitHub mirror consistent. The vault is always the source of truth — this skill pushes vault content *to* GitHub, never the other way. Uses native GitHub sub-issues (`gh issue create --parent`, `gh --version` ≥ 2.94.0) so a subtask's issue body can be small and self-contained instead of the whole feature's context.

**Target repo is always `JKneedler/questvale`** (the Flutter app repo where the coding sessions and PRs happen) — pass `--repo JKneedler/questvale` explicitly on every `gh issue` call, regardless of whether this session's cwd is the vault or the Flutter repo. Never target `questvale-vault` — that repo exists only for syncing this vault itself (e.g. mobile access) and is unrelated to ticket issues.

## Mirroring rule

- Only tickets at `status: Next` or later get a parent GitHub issue. Don't open one for anything still in `Backlog`.
- Sub-issues are opened **just-in-time**, one at a time, only for the specific subtask the user is about to work — not proactively for every subtask in a ticket the moment the parent issue exists.

## Two sync modes

### 1. Parent issue (ticket-level)

1. Read the ticket note's frontmatter: `status`, `github_issue`.
2. If `status: Backlog` and `github_issue` is empty — stop and say so; don't create an issue unless the user explicitly overrides.
3. If `status` is `Next`/`In Progress`/`Review` and `github_issue` is empty — **create it**:
   - Build the body from the ticket's actual content only: Summary, Design References (resolve each `[[wikilink]]` to plain text — a GitHub issue body can't follow vault links — either the note's title as a plain label, or a one-line inlined fact if it's directly relevant), Out of Scope, and a plain-text checklist of the subtask titles (not yet linked to issues — they link automatically once a subtask's sub-issue is created with `--parent`).
   - Write the body to a scratch file, then:
     ```
     gh issue create --repo JKneedler/questvale --title "<area>: <ticket title>" --body-file <scratch-file>
     ```
   - Write the returned issue number into the ticket's `github_issue:` frontmatter field.
4. If `github_issue` is already set — **resync**: rebuild the body the same way and run `gh issue edit <n> --repo JKneedler/questvale --body-file <scratch-file>`.
5. If `status: Done` and the issue is open — `gh issue close <n> --repo JKneedler/questvale`.

### 2. Sub-issue (subtask-level)

Only do this for the specific subtask the user names or is actively about to work.

1. The parent issue must exist first — if the ticket's `github_issue` is empty, run the parent flow above first.
2. Read that subtask's own `status`/`github_issue` fields (inside its subsection, not the ticket's top frontmatter).
3. If `github_issue` is empty and `status` is `Next`/`In Progress` — **create it**:
   - Body = ONLY that subtask's User Story, Acceptance Criteria, and Out of Scope, plus any Design Reference content actually needed for that specific subtask (briefly inlined, not the ticket's whole reference list), plus a line linking back to the vault ticket's file path and subtask heading so the full context is reachable if needed.
   - ```
     gh issue create --repo JKneedler/questvale --title "<ticket title>: <subtask title>" --body-file <scratch-file> --parent <parent-issue-number>
     ```
   - Write the returned number into that subtask's own `github_issue:` line in the vault note.
4. If already set — resync via `gh issue edit <n> --repo JKneedler/questvale --body-file <scratch-file>`.
5. If subtask `status: Done` and its issue is open — close it.

## Vault-side bookkeeping

Every time a `github_issue` number is written or changed, **commit that edit on its own** in the vault repo (e.g. `Link Tasks & Habits subtask 2 to questvale#14`) — this is what makes drift visible instead of silent. Don't bundle it with unrelated vault edits.

## Guardrails

- Never invent issue-body content beyond what's actually written in the vault ticket — if a field is blank, omit it rather than filling in something plausible-sounding.
- Never open a subtask's sub-issue before its parent ticket issue exists.
- Never open an issue for anything still in `Backlog` without an explicit override from the user.
- If `gh issue view <n>` shows the issue was manually changed on GitHub in a way that conflicts with the vault (e.g. closed on GitHub but the vault still says `In Progress`), stop and ask which side is correct rather than silently overwriting either one.
- Always pass `--repo JKneedler/questvale` explicitly — never rely on the session's cwd to imply the target repo.
