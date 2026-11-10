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

Minh


**Prompts 01–03.** 

```
[08/11/2026 16:20] | SESSION_END | global | Prompt 01: Reviewed the repository and project brief, confirmed there was no database implementation, and identified V1 deliverables and open questions
[08/11/2026 17:00] | SESSION_END | global | Prompt 02: Published the database requirements specification in chat with traceability, data scenarios, and V1/V2 scope
[08/11/2026 17:20] | DECISION | global | Prompt 03: User approved Clarify after confirming PostgreSQL 17.11, account and chat rules, reporting, and the group E2EE scope
```

**Prompt 04 and refinement**

Minh

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


Trang
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
[08/11/2026 18:39] | SESSION_START | project-setup | Plan V1 JavaFX screen coding; checked environment: Temurin JDK 25.0.4.1, Maven 3.9.16 bundled with IntelliJ IDEA 2026.2.3 (not on PATH), no Scene Builder, no JavaFX in local Maven repo, drive C: 0.8 GB free
[08/11/2026 18:39] | DECISION | project-setup | Split V1 UI work into 3 features for separate commits: project-setup, ui-user-screens, ui-admin-screens
[08/11/2026 18:39] | PLAN_CREATED | project-setup | Created docs/ai/project-setup/plan.md - approach: Maven multi-module (src/common, src/user, src/admin) + Maven Wrapper, --release 21, JavaFX 21.0.6, shared theme.css
[08/11/2026 18:39] | PLAN_CREATED | ui-user-screens | Created docs/ai/ui-user-screens/plan.md - approach: 13 FXML views + controllers matching prototype boards S01-S09, D01-D03, sample data, FXML load test
[08/11/2026 18:39] | PLAN_CREATED | ui-admin-screens | Created docs/ai/ui-admin-screens/plan.md - approach: 11 FXML views + controllers matching boards S10-S17, BarChart for A6/A9, FXML load test
[08/11/2026 18:39] | NOTE | project-setup | .gitignore is a Node.js template with no Java entries; plan appends a Java section and leaves Node entries unchanged
[08/11/2026 18:39] | QUESTION | project-setup | Asked user: Minh's JDK version; free space on C: or move Maven repository to D:
[08/11/2026 18:39] | QUESTION | ui-user-screens | Asked user: V1 navigation wiring, hardcoded sample data, Ikonli vs SVGPath icons, system vs bundled fonts, ScreenshotTool
[08/11/2026 18:39] | SESSION_END | project-setup | 3 plans AWAITING_APPROVAL; no code written
[08/11/2026 19:30] | SESSION_START | project-setup | Start coding V1 skeleton after plan approval
[08/11/2026 19:30] | PLAN_APPROVED | project-setup | User approved plan; Minh's JDK is above 21; user freed drive C: (1.2 GB free), Maven repository stays on C:
[08/11/2026 19:30] | PLAN_APPROVED | ui-user-screens | User approved plan with all recommendations: navigation wiring, SampleData, Ikonli Feather icons, Segoe UI + Consolas, ScreenshotTool
[08/11/2026 19:30] | PLAN_APPROVED | ui-admin-screens | User approved plan; shared decisions follow ui-user-screens answers
[08/11/2026 19:30] | CODE_START | project-setup | Creating parent POM, Maven Wrapper, common/user/admin modules
[08/11/2026 19:37] | FILE_CREATED | project-setup | pom.xml, src/common/pom.xml, src/user/pom.xml, src/admin/pom.xml
[08/11/2026 19:37] | FILE_CREATED | project-setup | src/common/src/main/resources/com/chatapp/common/theme.css
[08/11/2026 19:37] | FILE_CREATED | project-setup | src/user/src/main/java/com/chatapp/user/UserApp.java, src/admin/src/main/java/com/chatapp/admin/AdminApp.java
[08/11/2026 19:37] | FILE_CREATED | project-setup | mvnw, mvnw.cmd, .mvn/wrapper/maven-wrapper.properties (generated with IntelliJ-bundled Maven 3.9.16: mvn -N wrapper:wrapper -Dmaven=3.9.9)
[08/11/2026 19:37] | FILE_MODIFIED | project-setup | .gitignore - appended Java/Maven/IDE section
[08/11/2026 19:37] | BUG_FOUND | project-setup | Background launch failed: "'mvnw.cmd' is not recognized" because NoDefaultCurrentDirectoryInExePath=1 in this environment
[08/11/2026 19:37] | BUG_FIXED | project-setup | Launch mvnw.cmd by full path with Start-Process -WorkingDirectory; documented ".\mvnw.cmd" usage in feature doc
[08/11/2026 19:37] | CODE_DONE | project-setup | Skeleton implemented as planned
[08/11/2026 19:37] | VERIFIED | project-setup | 1) mvnw package exit 0, 3 jars built, theme.css in common jar - PASS; 2) user javafx:run window opened, clean log - PASS; 3) admin javafx:run process alive, clean log - PASS (window hidden behind VS Code in capture); 4) git status shows no target/ - PASS
[08/11/2026 19:37] | NOTE | project-setup | JDK 25 prints harmless native-access/Unsafe warnings from Maven 3.9.9 and JavaFX NativeLibLoader; left as is
[08/11/2026 19:37] | NOTE | global | .gitignore entry ".agent/" also ignores code/.agent/rules/rule.md; src/user/.gitkeep and src/admin/.gitkeep now redundant; left unchanged
[08/11/2026 19:37] | DOC_CREATED | project-setup | Created docs/ai/project-setup/project-setup.md
[08/11/2026 19:37] | COMMIT_REMINDER | project-setup | Reminded user: feat(project-setup): add Maven multi-module JavaFX skeleton with shared theme
[08/11/2026 19:37] | SESSION_END | project-setup | project-setup DONE; ui-user-screens next after the user commits
[08/11/2026 19:43] | SESSION_START | ui-user-screens | User committed project-setup (d60fe42 on feature/project-setup); start user screens
[08/11/2026 19:43] | CODE_START | ui-user-screens | Navigator, SampleData, 13 FXML views + controllers, user.css, FxmlLoadTest, ScreenshotTool
[08/11/2026 19:45] | PLAN_UPDATED | ui-user-screens | Iteration 1: shared ChatViews helper for conversation cells, avatars and bubbles
[08/11/2026 19:58] | FILE_MODIFIED | ui-user-screens | pom.xml, src/user/pom.xml - Ikonli 12.3.1 (javafx + feather), JUnit 5.11.4
[08/11/2026 19:58] | FILE_CREATED | ui-user-screens | Navigator.java, sample/SampleData.java, controller/ChatViews.java + 13 controllers, 13 FXML views, user.css
[08/11/2026 19:58] | FILE_CREATED | ui-user-screens | test: FxmlLoadTest.java (+FxTestSupport), ScreenshotTool.java
[08/11/2026 19:58] | BUG_FOUND | ui-user-screens | Screenshots: selected conversation row empty, outgoing bubble text black on black, "Gửi" button shrunk to "…", chat header title top-aligned
[08/11/2026 19:58] | BUG_FIXED | ui-user-screens | Probe showed selected cell graphic had no CSS/skin (added during layout) - ScreenshotTool takes a warm-up snapshot; Text nodes get style class "text" via ChatViews.text(); send buttons minWidth=USE_PREF_SIZE; header VBox alignment CENTER_LEFT
[08/11/2026 19:58] | BUG_FOUND | ui-user-screens | A PowerShell bulk edit failed to read files (wrong .NET current dir) but wrote 3 empty FXML files into the repo root
[08/11/2026 19:58] | BUG_FIXED | ui-user-screens | Edits redone with the Edit tool; the 3 empty stray files deleted (checked 0 bytes first)
[08/11/2026 20:00] | PLAN_UPDATED | ui-user-screens | Iteration 2: theme.css fixes (combo-box cell, arrow buttons, checkbox mark), vi-VN locale for DatePicker, NavigationTest for criterion 2
[08/11/2026 20:00] | FILE_MODIFIED | ui-user-screens | src/common/.../theme.css - combo-box list cell, arrow buttons transparent, checkbox -fx-mark-color white
[08/11/2026 20:00] | FILE_CREATED | ui-user-screens | src/user/src/test/java/com/chatapp/user/NavigationTest.java
[08/11/2026 20:01] | BUG_FOUND | ui-user-screens | NavigationTest: showMain only swapped content of a stale MainController because buildMain() also wrote the static Navigator.main field
[08/11/2026 20:01] | BUG_FIXED | ui-user-screens | Navigator keeps the MainController as the root's user data; showMain checks the root actually on screen; static field removed
[08/11/2026 20:02] | CODE_DONE | ui-user-screens | 13 views implemented; interactive states needing logic left for V2 (listed in feature doc)
[08/11/2026 20:02] | VERIFIED | ui-user-screens | mvnw -pl src/user test: 23/23 PASS (FxmlLoadTest 19, NavigationTest 4); ScreenshotTool wrote 13 PNGs, all reviewed against prototype; javafx:run alive 20 s with clean log
[08/11/2026 20:02] | DOC_CREATED | ui-user-screens | Created docs/ai/ui-user-screens/ui-user-screens.md
[08/11/2026 20:02] | COMMIT_REMINDER | ui-user-screens | Reminded user: feat(ui-user-screens): add JavaFX screens for the user subsystem
[08/11/2026 20:02] | SESSION_END | ui-user-screens | ui-user-screens DONE; ui-admin-screens next after the user commits
[08/11/2026 20:51] | SESSION_START | ui-admin-screens | User committed ui-user-screens (4946313 on feature/ui-user-screens); start admin screens
[08/11/2026 20:51] | CODE_START | ui-admin-screens | AdminNavigator, SampleData, 11 FXML views + controllers, admin.css, BarCharts, tests
[08/11/2026 20:52] | PLAN_UPDATED | ui-admin-screens | Iteration 1: Tables + MonthlyChart helpers, FxTestSupport, NavigationTest
[08/11/2026 20:52] | FILE_MODIFIED | ui-admin-screens | src/admin/pom.xml - Ikonli + JUnit 5
[08/11/2026 20:57] | FILE_CREATED | ui-admin-screens | AdminNavigator, sample/SampleData, controller/Tables, controller/MonthlyChart, 11 controllers, 11 FXML views, admin.css
[08/11/2026 20:57] | FILE_CREATED | ui-admin-screens | test: FxTestSupport, FxmlLoadTest, NavigationTest, ScreenshotTool
[08/11/2026 20:58] | BUG_FOUND | ui-admin-screens | FXML "IntegerSpinnerValueFactory is not a valid type" (dotted import and SpinnerValueFactory.IntegerSpinnerValueFactory element both rejected)
[08/11/2026 20:59] | BUG_FIXED | ui-admin-screens | Spinners use Spinner(min, max, initialValue) constructor args
[08/11/2026 20:59] | BUG_FOUND | ui-admin-screens | NavigationTest looked for texts inside table cells / column headers, which do not exist without a skin
[08/11/2026 20:59] | BUG_FIXED | ui-admin-screens | Assertions check page labels instead
[08/11/2026 21:00] | BUG_FOUND | ui-admin-screens | Screenshots: DatePicker "1/11/2026" (admin) and "12/5/2004" (user, already committed - the ui-user-screens doc wrongly said dd/MM/yyyy); vertical borders on selected table row; chart card cut at window bottom
[08/11/2026 21:00] | PLAN_UPDATED | ui-admin-screens | Iteration 2: common DateFields helper (common gets javafx-controls), theme row fixes, chart bottom padding; also touches user Register/Profile controllers
[08/11/2026 21:02] | FILE_CREATED | ui-admin-screens | src/common/src/main/java/com/chatapp/common/DateFields.java
[08/11/2026 21:02] | FILE_MODIFIED | ui-admin-screens | src/common/pom.xml, src/common/.../theme.css, src/user/.../RegisterController.java, ProfileController.java, 5 admin controllers, admin.css, NewUsersView/ActiveUsersView.fxml
[08/11/2026 21:02] | BUG_FIXED | ui-admin-screens | Dates show 01/11/2026 and 12/05/2004; selected rows without cell borders; chart card fully visible; admin login footer shortened (was truncated)
[08/11/2026 21:04] | FILE_MODIFIED | ui-user-screens | docs/ai/ui-user-screens/ui-user-screens.md - corrected the date-format statement; docs/screens/user/S09-ho-so.png regenerated
[08/11/2026 21:04] | CODE_DONE | ui-admin-screens | 11 views implemented; actions/filters left for V2 (listed in feature doc)
[08/11/2026 21:04] | VERIFIED | ui-admin-screens | Full install: user 24/24, admin 24/24 tests PASS; 13 admin screenshots reviewed; admin javafx:run alive 20 s with clean log; requirement checklist A1a-A9 complete
[08/11/2026 21:04] | DOC_CREATED | ui-admin-screens | Created docs/ai/ui-admin-screens/ui-admin-screens.md
[08/11/2026 21:04] | COMMIT_REMINDER | ui-admin-screens | Reminded user: feat(ui-admin-screens): add JavaFX screens for the admin subsystem
[08/11/2026 21:04] | SESSION_END | ui-admin-screens | V1 screens for both subsystems DONE

```



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
| project-setup | ✅ | ✅ | ✅ | ✅ | ✅ |
| ui-user-screens | ✅ | ✅ | ✅ | ✅ | ✅ |
| ui-admin-screens | ✅ | ✅ | ✅ | ✅ | ⬜ |
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
