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

### [08/11/2026]
```
[08/11/2026 17:23] | SESSION_START | requirements-analysis | Read Final Project.pdf, rule.md, README.md, roadmap, framework notes and existing design-ui/ mockups; goal: list ambiguities, write use-case specification, build clickable prototype before any UI code
[08/11/2026 17:23] | NOTE | global | Figma connector is not authorized in this session; prototype will be built as an HTML artifact instead of a Figma file
[08/11/2026 17:23] | NOTE | global | Conflicting tech stack in repo: README.md says React + MySQL, work-log DECISION says JavaFX + Spring Boot + PostgreSQL; React violates the Java-only frontend requirement. Left unchanged, raised with user
[08/11/2026 17:23] | NOTE | global | rule.md references docs/ai/templates/ but the real folder is docs/ai/_template/; left unchanged (out of scope)
[08/11/2026 17:24] | PLAN_CREATED | requirements-analysis | Created docs/ai/requirements-analysis/plan.md - approach: requirement ambiguity list + use-case specification (docs only) + HTML clickable prototype; no Java code
[08/11/2026 17:46] | FILE_CREATED | requirements-analysis | docs/ai/requirements-analysis/use-case-specification.md - 6 blocking issues (K1-K6), 23 ambiguities with proposed defaults (M1-M23), 45 use cases, traceability matrix, BR-01..BR-15, screen inventory
[08/11/2026 17:46] | DECISION | requirements-analysis | Prototype built as a claude.ai Design canvas (22 linked artboards) instead of Figma; Figma connector not authorized
[08/11/2026 17:46] | BLOCKED | requirements-analysis | Drive C: has 0 GB free; writing to the session scratchpad failed with ENOSPC. Moved prototype source to design-ui/prototype-canvas/ on drive D:
[08/11/2026 17:46] | PLAN_UPDATED | requirements-analysis | Iteration 1: single HTML file replaced by Design canvas with 22 artboards; source path changed to ../design-ui/prototype-canvas/ because drive C: is full
[08/11/2026 17:46] | FILE_CREATED | requirements-analysis | ../design-ui/prototype-canvas/ (project/canvas.json, 22 project/*.dc.html boards, assets/app.css), published to https://claude.ai/artifact/MxZtuhNSYunZ2YF3Z4odwA
[08/11/2026 17:46] | VERIFIED | requirements-analysis | Criteria 1-2 PASS (traceability and UC structure checked against PDF); criterion 3 NOT RUN - click-through must be done by the user in Play mode
[08/11/2026 17:46] | DOC_CREATED | requirements-analysis | Created docs/ai/requirements-analysis/requirements-analysis.md
[08/11/2026 17:46] | QUESTION | requirements-analysis | Asked user to confirm: tech stack (K1), 3-jar architecture (K3), group encryption design (K4), deadlines (K5), and defaults M7, M12, M15, M17, M18
[08/11/2026 17:46] | COMMIT_REMINDER | requirements-analysis | Reminded user: docs(requirements-analysis): add use-case specification and prototype review
[08/11/2026 17:46] | SESSION_END | requirements-analysis | Spec and 22-screen prototype done; waiting for user review before planning the UI coding feature
[08/11/2026 18:25] | SESSION_START | requirements-analysis | Apply user answers to open questions K1, K3, K4, K5
[08/11/2026 18:25] | DECISION | requirements-analysis | User confirmed: DB = PostgreSQL (K1), 3-jar architecture server/user/admin + config.properties (K3), simple group encryption with server-held key (K4), V1 22/11/2026 and V2 12/12/2026 (K5); other [ĐX] defaults accepted except M7, M12, M15, M17, M18 (answer pending)
[08/11/2026 18:25] | PLAN_UPDATED | requirements-analysis | Iteration 2: E2EE design replaced by encryption at rest with per-group AES-256 key wrapped by crypto.masterKey; README.md added to file list
[08/11/2026 18:25] | FILE_MODIFIED | requirements-analysis | README.md - stack table (React->JavaFX, MySQL->PostgreSQL, added plain socket + 3-jar note), member roles, deadlines V1 22/11/2026 and V2 12/12/2026, folder structure (src/admin, src/user, src/server, script, release, git, docs/ai), checklist MySQL->PostgreSQL
[08/11/2026 18:25] | FILE_MODIFIED | requirements-analysis | docs/ai/requirements-analysis/use-case-specification.md - v0.2: K1/K3/K4/K5 marked resolved, UC-28 rewritten for server-held key, E2EE references removed from UC-04/06/20/21/22/24/26/36, section 8 updated
[08/11/2026 18:25] | FILE_MODIFIED | requirements-analysis | ../design-ui/prototype-canvas/project/{U-GroupChat,D-CreateGroup,U-Chat,U-ForgotPassword,U-Profile,A-UserDialogs}.dc.html - removed E2EE wording, fingerprint and key re-share notes; AI button enabled in group chat; republished artifact
[08/11/2026 18:25] | NOTE | global | README folder structure lists src/server/ for server.jar; exact location to be confirmed in the socket-server plan
[08/11/2026 18:25] | QUESTION | requirements-analysis | Still open: M7 (friends-of-friends count), M12 (block also blocks 1-1 chat), M15 (delete history only on own side), M18 (member permissions in group), M17 (LLM provider)
[08/11/2026 18:25] | COMMIT_REMINDER | requirements-analysis | Reminded user: docs(requirements-analysis): add use-case specification, prototype and fix README stack
[08/11/2026 18:25] | SESSION_END | requirements-analysis | Decisions applied to spec, README and prototype; waiting for answers to questions 5-9
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
| requirements-analysis | ✅ | ✅ | 🔄 | ✅ | ⬜ |
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
