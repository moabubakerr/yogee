---
name: changes-log
description: Write or update the dated entries in changes-log/ that record what changed in this repo and why. Use when asked to log changes, write up a session, update the changelog, or record what was done — and offer it after a batch of edits is finished.
---

# Changes log

Entries live in `changes-log/` at the repo root. One file per day:

```
changes-log/YYYY-MM-DD-short-slug.md
changes-log/README.md        <- index table, one row per file
```

A second session on the same day **appends** to that day's file under a new
`##` heading. Do not create `-part2`.

## Before writing, gather facts — do not write from memory

```bash
git status --short
git diff --stat
git log --oneline --since="<yesterday>"
```

Read the actual diff for anything you are about to describe. A log entry that
misstates a number is worse than no entry: someone will trust it instead of
reading the code. If a change was tried and reverted, that belongs in the entry
too — it stops the next person retrying it.

Today's date comes from the environment context, not from a guess.

## What an entry is for

The diff already says *what* changed. This file says **why**, and what it cost.
For each change worth recording:

- The problem, with the numbers that made it a problem ("364pt design, 396pt
  needed with margins, no phone has it").
- The fix, and why that approach over the obvious alternative.
- What was traded away, stated plainly — a clamped text scale, an approximated
  line height, a widened gap that scrolls sooner. Never quietly omit these.
- Anything discovered along the way: a mismatched constant, a silent clip, a
  field that does not do what its name suggests.

Skip: formatting-only edits, dependency bumps with no behaviour change,
anything already obvious from the commit message.

## Shape

```markdown
# YYYY-MM-DD — short title

Branch: `name`

One or two sentences on the shape of the work.

---

## Area — what changed

`path/to/file.dart`

**Problem.** ...

**Fix.** ...

- Trade-offs and gotchas as bullets.

---

## Verification status

What was run, what passed, what was NOT checked.
```

Reference code as `file.dart:123` so it stays clickable. Quote real constant
names and real values.

## The verification section is required

Every entry ends with one. State what was actually run (`flutter analyze`,
`flutter test`, a device install) and what was not. If layout changes were
reasoned about but never seen on a screen, say exactly that. Never let an entry
imply more confidence than the work earned.

## After writing

1. Add or update the row in `changes-log/README.md`.
2. Tell the user the path. Do not commit unless asked.

## Project-specific care

This repo has traps a log entry can easily get wrong:

- **Which Firebase project.** Release builds hit production `yoogeeapp`; debug
  builds fall through to it too, because `android/app/src/debug/google-services.json`
  is missing. iOS has only one plist, also production. If an entry mentions
  running or building, say which backend it touched.
- **Generated vs hand-written.** `lib/flutter_flow/` and
  `lib/backend/schema/*_record.dart` are generated; `lib/custom_code/*.dart` at
  the root is the safe home for shared helpers. Note when a change lands in a
  file a FlutterFlow re-export would overwrite.
- **Remotes differ.** `origin`, `standalone`, and `upstream` do not carry the
  same commits. Name the one you mean.
