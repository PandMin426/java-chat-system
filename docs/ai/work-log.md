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

**Prompts 01–03.** 

```
[08/11/2026 16:20] | SESSION_END | global | Prompt 01: Reviewed the repository and project brief, confirmed there was no database implementation, and identified V1 deliverables and open questions
[08/11/2026 17:00] | SESSION_END | global | Prompt 02: Published the database requirements specification in chat with traceability, data scenarios, and V1/V2 scope
[08/11/2026 17:20] | DECISION | global | Prompt 03: User approved Clarify after confirming PostgreSQL 17.11, account and chat rules, reporting, and the group E2EE scope
```

**Prompt 04 and refinement**

```
[08/11/2026 18:19] | SESSION_START | global | Started Prompt 04 database design baseline after user approved Clarify
[08/11/2026 18:21] | DOC_CREATED | global | Created docs/database/design-baseline.md with entity groups, Mermaid ERDs, and dependency order for PostgreSQL 17.11
[08/11/2026 18:22] | DECISION | global | Documented a proposed key-epoch and device-grant model for group encryption pending backend and UI alignment
[08/11/2026 18:22] | SESSION_END | global | Statically checked 16 entities and 25 FK relationships against four dependency stages; baseline awaiting user review
[08/11/2026 18:32] | SESSION_START | global | Reviewed the database design baseline for four requested refinements before Core Database implementation
[08/11/2026 18:32] | DECISION | global | User accepted the baseline in principle and requested limited integrity refinements while preserving E2EE scope and deferring SQL until approval
[08/11/2026 18:32] | BUG_FOUND | global | Baseline did not specify database enforcement for private sender membership, same-group references, duplicate open memberships, or identifier uniqueness after anonymization
[08/11/2026 18:33] | FILE_MODIFIED | global | Updated docs/database/design-baseline.md with sender validation, composite group FKs, conditional uniqueness, soft-delete behavior, and E2EE responsibility boundaries
[08/11/2026 18:33] | SESSION_END | global | Reviewed the four documentation changes and checked whitespace; awaiting user approval to implement Core Database
[08/11/2026 18:39] | SESSION_START | global | Started Prompt 05 Core Database implementation after the user approved the refined baseline
[08/11/2026 18:40] | FILE_CREATED | global | Created script/schema.sql with users, login_events, app_open_events, constraints, indexes, and a user lifecycle guard
[08/11/2026 18:42] | VERIFIED | global | PASS on fresh PostgreSQL 17.11: exact table scope and TIMESTAMPTZ, case-sensitive usernames, case-insensitive email uniqueness, role/status checks, PK/FK checks, soft delete with identifier reuse and preserved history, and Vietnam-time activity counts
[08/11/2026 18:42] | SESSION_END | global | Core schema and database checks complete; backend authentication and event capture were not tested; awaiting user review before expanding the schema
[08/11/2026 18:51] | SESSION_START | global | Started Prompt 05 Core Database refinement and verification after user review
[08/11/2026 18:52] | FILE_MODIFIED | global | Updated script/schema.sql with a global chronological login index, immutable created_at and registration_source, and email trimming before profile and uniqueness checks
[08/11/2026 18:53] | VERIFIED | global | Checked Docker with docker ps, docker ps -a, and docker inspect chat-postgres; direct checks on chat-postgres NOT RUN because it was stopped; used its exact local image in a temporary container instead
[08/11/2026 18:53] | VERIFIED | global | Ran docker run --detach --rm --pull never --network none with POSTGRES_DB=java_chat_core_refine_test and the chat-postgres image; docker exec psql SHOW server_version_num returned 170011; ran schema.sql and transactional SQL assertions via stdin with docker exec -i and psql -X -U postgres -d java_chat_core_refine_test -v ON_ERROR_STOP=1
[08/11/2026 18:53] | VERIFIED | global | Seven groups PASS, zero FAIL: clean schema, normalized uniqueness, status checks, lifecycle trigger, event foreign keys, global login order and index EXPLAIN, and soft delete with retained history and reusable identifiers
[08/11/2026 18:53] | SESSION_END | global | Rolled back test data and removed the temporary container with docker stop; Core Database awaiting user review
[08/11/2026 19:01] | SESSION_START | global | Started Prompt 06 Social and Private Messaging implementation after user approved Core Database
[08/11/2026 19:04] | FILE_MODIFIED | global | Extended script/schema.sql with friend_requests, friendships, user_blocks, private_conversations, private_messages, private_message_hides, and spam_reports; kept Core DDL intact
[08/11/2026 19:04] | DECISION | global | Used ordered pair keys and READ COMMITTED pair locks to coordinate block cleanup and writes; used triggers for participant checks, append-only private messages, and spam eligibility
[08/11/2026 19:04] | FILE_MODIFIED | global | Updated docs/database/design-baseline.md with trigger enforcement, backend authorization, and the pair lock contract for accepting friend requests
[08/11/2026 19:04] | SESSION_END | global | Prompt 06 SQL execution and verification NOT RUN at user request; awaiting review before continuing
[08/11/2026 19:11] | SESSION_START | global | Started Prompt 06 refinement for duplicate pending requests and transactional acceptance
[08/11/2026 19:11] | FILE_MODIFIED | global | Updated script/schema.sql with a partial unique index for unordered pending pairs, reused the pair expression for block cleanup, and made the existing trigger reject non-PENDING inserts
[08/11/2026 19:11] | DECISION | global | Kept friendship creation in the backend; documented locking the pair, updating exactly one pending request, and inserting the friendship in the same READ COMMITTED transaction with rollback on failure
[08/11/2026 19:11] | SESSION_END | global | Refinement NOT TESTED at user request; awaiting review before Prompt 07
[08/11/2026 19:13] | SESSION_START | global | Started Prompt 07 Group Chat and E2EE database implementation after user approved Prompt 06
[08/11/2026 19:14] | FILE_MODIFIED | global | Extended script/schema.sql with chat_groups, group_memberships, group_messages, e2ee_devices, group_key_epochs, and group_key_grants; kept previous modules intact
[08/11/2026 19:14] | DECISION | global | Used group-scoped FKs, conditional uniqueness for open memberships, devices and epochs, and a message trigger that checks and locks current group state; kept key handling in the application
[08/11/2026 19:14] | FILE_MODIFIED | global | Documented backend responsibilities for group creation, admin checks, membership history, and epoch transitions in docs/database/design-baseline.md; recorded pending DL-16 coordination
[08/11/2026 19:15] | SESSION_END | global | Prompt 07 NOT TESTED at user request; awaiting review before Prompt 08
[08/11/2026 19:21] | SESSION_START | global | Started Prompt 08 verification and V1 delivery after user approved the Group Chat and E2EE database design
[08/11/2026 19:23] | BUG_FOUND | global | Reproduced cross-user E2EE key-grant insertion in an isolated database; also found missing epoch-start checks against membership and device authorization
[08/11/2026 19:23] | FILE_MODIFIED | global | Updated script/schema.sql with shared-owner foreign keys and epoch eligibility guards for grants and group messages
[08/11/2026 19:29] | FILE_CREATED | global | Prepared script/seed.sql covering all 16 tables and script/tests/verify.sql with seven SQL assertion groups
[08/11/2026 19:29] | VERIFIED | global | Ran SHOW server_version_num via docker exec on chat-postgres and the isolated copy; both returned 170011; used the same local image with docker run --rm --pull never --network none and a fresh java_chat_prompt08_verify database
[08/11/2026 19:29] | VERIFIED | global | Ran schema.sql, seed.sql, and verify.sql via docker exec -i psql -X -U postgres -d java_chat_prompt08_verify -v ON_ERROR_STOP=1; all passed; catalog showed 16 PK, 25 FK, 21 CHECK, 5 UNIQUE constraints, 44 indexes, and 10 application triggers
[08/11/2026 19:29] | VERIFIED | global | Two psql sessions reproduced a competing send waiting 5.87 seconds for an uncommitted block and then being rejected; stopped and removed the isolated verification container
[08/11/2026 19:29] | FILE_MODIFIED | global | Finalized docs/database/design-baseline.md for V1 with run instructions, verified inventory, and V2 boundaries; compared ERD fields and all 25 FK relationships with the final DDL
[08/11/2026 19:30] | SESSION_END | global | Final database verification complete with seven SQL groups and one concurrency case passing; backend and E2EE protocol NOT RUN; awaiting final review
[08/11/2026 19:33] | SESSION_START | global | Started the requested Prompt 08 delivery re-verification of the current workspace
[08/11/2026 19:34] | VERIFIED | global | SHOW server_version_num returned 170011 on chat-postgres; ran schema.sql, seed.sql, and verify.sql through psql -v ON_ERROR_STOP=1 in a separate java_chat_v1_final_review database using the exact local image without mounting existing volumes
[08/11/2026 19:34] | VERIFIED | global | Seven SQL assertion groups and the two-session block case PASS; concurrent send waited 5.86 seconds and was rejected; three ERDs match all 16 tables and 25 FK relationships; no new defect required a schema or fixture change
[08/11/2026 19:34] | SESSION_END | global | Removed the temporary container; backend and E2EE protocol NOT RUN; awaiting final user review
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
| database-design-baseline | ⬜ | ⬜ | ⬜ | 🔄 | ⬜ |
| core-database | ⬜ | ✅ | 🔄 | ⬜ | ⬜ |
| social-private-database | ⬜ | ✅ | ⬜ | ⬜ | ⬜ |
| group-e2ee-database | ⬜ | ✅ | ⬜ | ⬜ | ⬜ |
