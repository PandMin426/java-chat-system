# WORK-LOG.MD — AI Action Log

> **Project:** Java Chat System
> **Location:** `docs/ai/work-log.md` (one global file shared by all features)
> **Rule:** The AI MUST update this file for every important action (see Rule 3 in `rule.md`).

---

## 1. LOGGING RULES (READ BEFORE WRITING ANY ENTRY)

1. **Append-only.** Add new entries ONLY at the end of the `## 4. LOG ENTRIES` section, directly above the `APPEND NEW ENTRIES` marker comment. NEVER edit, delete, or reorder existing entries. To correct a mistake, add a new entry.
2. **One entry = one line.** Never split an entry across multiple lines.
3. **Entry format (exact):**
   ```
   [DD/MM/YYYY HH:MM] | <ACTION_TYPE> | <feature-name> | <details>
   ```
   - Use exactly one space on each side of every `|`. Do NOT pad or align columns.
   - `<ACTION_TYPE>` MUST be one of the types in section 2. Do NOT invent new types.
   - `<feature-name>` MUST match the folder name in `docs/ai/` (kebab-case). For actions that belong to no feature, use `setup` (project initialization) or `global` (anything else).
   - `<details>` MUST be written in English, concise, and specific (file paths, error messages, reasons).
4. **Timestamps MUST be real.** Use the real current local time in 24-hour format. If you can run commands, get it from the system (for example `date '+%d/%m/%Y %H:%M'`). If you cannot access a clock, ASK the user for the current date and time. NEVER guess or invent a timestamp.
5. **Daily headings.** Group entries under a heading `### [DD/MM/YYYY]`. When the date changes, add a new heading at the end of the log.
6. **Session boundaries.** Every session MUST begin with a `SESSION_START` entry and end with a `SESSION_END` entry.
7. **Progress table.** Update the table in section 5 whenever a feature's status changes. If you start a feature that is not in the table, add a new row for it.

---

## 2. ACTION TYPES

| Type | Meaning | Related rule |
|---|---|---|
| `SESSION_START` | A new working session begins | Rule 3 |
| `SESSION_END` | The working session ends (include a short result summary) | Rule 3 |
| `PLAN_CREATED` | `plan.md` created for a feature | Rule 1 |
| `PLAN_UPDATED` | `plan.md` updated because the approach changed (include iteration number and reason) | Rule 1 |
| `PLAN_APPROVED` | The user approved the plan; coding may start | Rule 7 |
| `QUESTION` | A question or assumption was raised with the user before or during coding | Rule 9 |
| `CODE_START` | Started writing code for a feature | Rule 1 |
| `CODE_DONE` | Finished writing code for a feature | Rule 5 |
| `FILE_CREATED` | A new file was created (include path) | Rule 3 |
| `FILE_MODIFIED` | An existing file was changed (include path and what changed) | Rule 3, 11 |
| `VERIFIED` | Success criteria from `plan.md` were checked (include what was checked and the result) | Rule 12 |
| `BUG_FOUND` | A bug or error was found (include the error message) | Rule 3 |
| `BUG_FIXED` | A bug was fixed (include how) | Rule 3 |
| `DECISION` | An important technical decision was made (include the reason) | Rule 3 |
| `NOTE` | An unrelated issue (for example dead code or a bug outside the scope) was noticed and intentionally NOT changed | Rule 11 |
| `REFUSED` | A request was refused because it violates a rule (for example WebSocket) and an alternative was proposed | Rule 8 |
| `BLOCKED` | Work is blocked by an unresolved problem | Rule 3 |
| `DOC_CREATED` | A documentation file was created (for example `<feature-name>.md`) | Rule 2 |
| `COMMIT_REMINDER` | The user was reminded to make a separate commit | Rule 4 |

---

## 3. TEMPLATE ENTRIES (REFERENCE ONLY — DO NOT COPY THE PLACEHOLDERS INTO THE LOG)

<!--
[DD/MM/YYYY HH:MM] | SESSION_START | <feature-name> | <session goal>
[DD/MM/YYYY HH:MM] | PLAN_CREATED | <feature-name> | Created docs/ai/<feature-name>/plan.md - approach: <short summary>
[DD/MM/YYYY HH:MM] | QUESTION | <feature-name> | Asked user: <question or assumption>
[DD/MM/YYYY HH:MM] | PLAN_APPROVED | <feature-name> | User approved the plan
[DD/MM/YYYY HH:MM] | CODE_START | <feature-name> | Started implementing <class/module>
[DD/MM/YYYY HH:MM] | FILE_CREATED | <feature-name> | src/.../<FileName>.java
[DD/MM/YYYY HH:MM] | FILE_MODIFIED | <feature-name> | src/.../<FileName>.java - <what changed>
[DD/MM/YYYY HH:MM] | BUG_FOUND | <feature-name> | Error: <description or message>
[DD/MM/YYYY HH:MM] | BUG_FIXED | <feature-name> | Fix: <how it was fixed>
[DD/MM/YYYY HH:MM] | NOTE | <feature-name> | Noticed unused method X in <file>; left unchanged (out of scope)
[DD/MM/YYYY HH:MM] | PLAN_UPDATED | <feature-name> | Approach changed because: <reason>. Iteration 2
[DD/MM/YYYY HH:MM] | CODE_DONE | <feature-name> | Implementation finished
[DD/MM/YYYY HH:MM] | VERIFIED | <feature-name> | Checked <criterion> by <method> - result: <pass/fail>
[DD/MM/YYYY HH:MM] | DOC_CREATED | <feature-name> | Created docs/ai/<feature-name>/<feature-name>.md
[DD/MM/YYYY HH:MM] | COMMIT_REMINDER | <feature-name> | Reminded user: feat(<feature-name>): <message>
[DD/MM/YYYY HH:MM] | SESSION_END | <feature-name> | <summary of session result>
-->

---

## 4. LOG ENTRIES

### [24/10/2026]
```
[24/10/2026 19:24] | SESSION_START | setup | Initialized project, created docs/ai/ structure
[24/10/2026 19:25] | FILE_CREATED | setup | Created work-log.md template
[24/10/2026 19:25] | FILE_CREATED | setup | Created plan.md template
[24/10/2026 19:25] | DECISION | setup | Chose tech stack: JavaFX + Spring Boot + PostgreSQL + Java Socket
[24/10/2026 19:25] | SESSION_END | setup | Finished setting up templates and rules
```

<!-- APPEND NEW ENTRIES DIRECTLY ABOVE THIS LINE (chronological order, newest at the bottom). Keep this marker as the LAST line of section 4. Do NOT write below it. -->

---

## 5. PROGRESS TRACKER

**Legend:** ⬜ not started | 🔄 in progress | ✅ done

**Update rule:** Update the matching row whenever a feature's status changes. Mark a column ✅ only when it is really complete:
- **Plan** = `plan.md` exists and is fully filled in (Rule 1).
- **Code** = implementation is finished.
- **Verified** = every success criterion in `plan.md` was checked and passed (Rule 12).
- **Doc** = `docs/ai/<feature-name>/<feature-name>.md` exists (Rule 2).
- **Committed** = the user confirmed the separate commit `feat(<feature-name>): ...` (Rule 4).

| Feature | Plan | Code | Verified | Doc | Committed |
|---|---|---|---|---|---|
| socket-server | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| socket-client | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| auth | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| chat-1-1 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| group-chat | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| friend-system | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| spam-report | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| admin-user-mgmt | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| admin-stats | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| email-reset-pw | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| llm-integration | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| group-encryption | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
