# PLAN — database-schema

| Field | Value |
|---|---|
| Feature name | `database-schema` |
| Created | 19/11/2026 |
| Owner(s) | Minh |
| Status | `IN_PROGRESS` |
| Plan approved by user | YES (19/11/2026) |
| Design decisions | Q1=B, Q2=A, Q3=B (`membership_periods`), Q4=A; confirmed by Minh on 19/11/2026 |
| Detailed decisions | R1=B, R2=A; explicitly confirmed by Minh on 19/11/2026 |
| Detailed design approved by user | YES (19/11/2026), explicit approval received before schema implementation |
| Session scope | Final review of approved decisions, actual SQL/tests, Git changes and recorded evidence; edit only this plan, database-schema.md, design-baseline.md and work-log.md/tracker; SQL/application/README/use-case/UI read-only; no unnecessary rerun or commit/push/merge |
| Current review gate | No unanswered named design choice; major DDL changes still require review. A DB constraints / B query results / C SQL contract simulations / D real integration are reported separately |
| Time zone | `Asia/Ho_Chi_Minh`; date obtained from the live clock, UTC+07:00 |

## 1. SUMMARY

Redesign PostgreSQL DDL for the confirmed requirements with declarative constraints and a shared conversation model. Minh approved the plan and detailed design, including Q1–Q4=B/A/B/A and R1=B/R2=A. Iteration 5 delivered matching fixtures, nine parameterized queries and isolated tests. Schema→seed→queries→verification ran on the explicitly identified new test database only: A=48 PASS, B=40 PASS, C=11 SQL simulations PASS. Iteration 6 reviews that unchanged implementation and its evidence, completes decision traceability/handoff and retains IN_PROGRESS because required database acceptance cases remain NOT RUN. Real application/E2EE integration is downstream work; no new design answer is inferred.

### Repository and source review

- Repository: `D:\java-chat-system`, branch `fix/db`, origin `git@github.com:PandMin426/java-chat-system.git`.
- Initial `git status --short`: only `?? docs/Phuong_an_da_chot_JAVA_CHAT_SYSTEM.docx`. This pre-existing source must remain unchanged and untracked unless Minh acts separately. No tracked modifications were present.
- No `AGENTS.md` was found in the repository or its drive-root ancestor. `.agent/rules/rule.md` is the applicable local workflow. Its `docs/ai/templates/` reference is stale; use the actual `docs/ai/_template/` files, as explicitly requested, without renaming them.
- At the initial planning review no database-schema feature existed. The approved plan, feature document and iterations 1–4 now exist and were reread/preserved before iteration 5.
- Read both `_template` files; the `ui-admin-screens` plan and feature document; all of `docs/ai/work-log.md`; `script/schema.sql`, `script/seed.sql`, `script/tests/verify.sql`; `docs/database/design-baseline.md`; `docs/Final_Project_He_Thong_Chat_Chi_Tiet.md`; and `docs/ai/requirements-analysis/use-case-specification.md`.
- Successfully read `docs/Phuong_an_da_chot_JAVA_CHAT_SYSTEM.docx` through its OOXML document body, including table-cell text (152 paragraphs). The Word source is available; no missing-source assumption is needed. This was a content review, not a Word layout audit. Its decision numbering omits D40; do not invent a D40 decision.
- Source priority: Minh's explicit decisions in this request, including O1–O4, Q8=A and S1, override conflicting Word and older documents. Use the Word decisions for other business rules. Older SQL, baseline and use cases describe the current implementation or historical choices, not approval for this redesign. UI documents describe sample screens, not implemented JDBC/server behavior.

### Original-schema gap analysis (before this implementation)

The table below preserves the initial source review of the old files. schema.sql now declares the approved 15-table model and it has run in a new dedicated test database. Current runtime evidence is in section 9, baseline section 12 and script/tests/negative-cases.md; no business database was queried or changed.

| Area | Current files | Required change and responsibility |
|---|---|---|
| Enforcement | `schema.sql` has 16 tables, 10 business triggers and 12 custom functions, including pair-lock helpers | Replace business enforcement with allowed declarative objects and documented application transactions; retain no custom function as a trigger substitute |
| Username | Case-sensitive partial uniqueness; no 3–30 ASCII character constraint | Required profile, `^[A-Za-z0-9_]{3,30}$`, global case-insensitive uniqueness, and matching application login lookup |
| Email and deletion | Email case-insensitive only for non-deleted accounts; trigger trims email; deletion nulls profile and releases identifiers | O1: case-insensitive email; retain profile and globally reserve username/email after `deleted_at` is set; application normalizes input |
| Login and activity | `login_events` has ID/time only; separate `app_open_events`; names read from current profile | `login_history` stores successful UserApp login time and name/username snapshots; each row is one app open; AdminApp logins go to administration audit only (O3) |
| Conversation model | `private_conversations/private_messages` and `chat_groups/group_memberships/group_messages` are separate | Shared `conversations`, `conversation_members`, `messages`; S1 keeps the ordered PRIVATE endpoints directly in `conversations` |
| Personal history | Only `private_message_hides`; full clear requires many hide rows; no read cursor | Shared `message_hidden`, member `cleared_at` and `last_read_message_id`; filter history, search, jump results and unread counts consistently |
| Social rules | Ordered friendship and unordered pending-request uniqueness already exist; triggers perform cleanup; reverse invite can fail as a duplicate | Preserve pair uniqueness; application transaction auto-accepts reverse invites, permits re-invites after rejection, and cleans up friendship/pending requests on block |
| Block | Existing trigger/helper enforcement; server must already filter search | Apply D18 search/invite restrictions and two-way private-send prevention in application transactions; shared group chat remains allowed |
| Groups | Baseline/seed create two-person groups; baseline limits adding members to admins and closes a group when its last admin account is deleted | Create with at least three people; any member may add an eligible person; only group ADMIN renames, grants admin or removes members; O2 requires a selected successor, with Q1=B permitting exceptional closure when no eligible successor exists; closure retains authorized history |
| E2EE | One current device per account and one open epoch per group already have partial unique indexes; temporal guards are triggers | Preserve those declarative limits and owner/group composite FKs; move eligibility/rotation checks to application transactions; enforce O4 session termination and no new grants to the old device in server/client integration |
| Spam | No reason, processing status or handler metadata; duplicates permitted; trigger accepts any message direction | Optional reason; `PENDING/RESOLVED/DISMISSED`; one PENDING per directed pair; application requires a PRIVATE message from reported user to reporter and implements D38 |
| Reports | Old second column includes direct friends; activity uses app-open events | Distinct level-two friends only, excluding self and every direct friend; UserApp login counts and distinct monthly login users; preserve historical send counts after hide/clear/delete |
| Audit and forced logout | No administration audit/control-delivery model | Record AdminApp authentication separately; document JDBC commit, TCP control request, acknowledgement and visible failure handling; persistence choice is Q2 |
| Fixtures and tests | Explicitly assert 16 tables, case-sensitive usernames, identifier reuse, duplicate reports and trigger rejections; temporary custom assertion function | Rewrite after approval; old PASS records cannot validate the new requirements; remove the custom assertion helper and use anonymous test assertions |

## 2. INPUT / OUTPUT

### Input

- Confirmed decisions listed in section 4, the Word D1–D43 decisions where not overridden, and the reviewed repository sources.
- A fresh, explicitly named disposable PostgreSQL test database; no existing application data is to be migrated.
- Minh's plan/detailed-design approvals and Q1–Q4=B/A/B/A, R1=B/R2=A, explicitly checked against this conversation. No unresolved DDL choice remains in the approved scope.

### Output / Expected result

- This session: four reviewed documents with decision-to-implementation traceability, exact prior A/B/C evidence, open database acceptance gates and a README/use-case/UI handoff list. SQL/test source stays unchanged and passing tests are not repeated without a relevant change.
- Result: coherent fresh-database SQL sources and truthful IN_PROGRESS documentation. No seed password/envelope is a real credential or cryptographic artifact.
- An explicit allocation of every rule to declarative DB enforcement, application transaction, or server/client integration, with reproducible evidence and remaining integration checks reported truthfully.

## 3. SCOPE

### In scope

- Accounts, retained soft deletion, password metadata, successful UserApp login snapshots, administration audit, social relationships, unified text messaging, stable per-user conversation state plus `membership_periods`, group roles and exceptional closure, spam processing, reporting queries and E2EE storage metadata.
- Fresh-database DDL using tables, identity, PK, FK, NOT NULL, UNIQUE, row-local CHECK, DEFAULT, indexes and justified partial unique indexes. Built-in expressions such as `lower` are permitted; no cross-table CHECK.
- Foreign keys that bind a message/read pointer/hide/grant to the correct conversation and a grant to the correct device owner.
- Application transaction contracts, lock order, rollback and retry rules, including races between block/send, reciprocal invites, admin transfer, and device/epoch changes. SQL simulations test these contracts without adding Java code.
- Query examples for Admin screens S11–S17 and User history/search; UTC instants stored as `timestamptz`, reporting boundaries explicitly in `Asia/Ho_Chi_Minh`.

### Out of scope

- This final review: SQL/test changes, database execution, business data, deleting/resetting databases or schemas, installing/configuring tools, application/README/use-case/UI edits and paths outside the four editable documents in section 6. Any discovered important design issue must be proposed before dependent changes.
- Later implementation: migration/backfill of old data, compatibility views for old table names, Java/FXML/CSS changes, JDBC or socket implementation, SMTP/LLM integration, E2EE algorithms or key generation/distribution implementation.
- Normal unencrypted groups, attachments, server plaintext search of group ciphertext, key transfer, backup or recovery secrets. Client group search remains an unimplemented integration item.
- Persistent online status, a speculative session database, business triggers, stored procedures, custom functions, fixed preservation of the old 16-table count, and changes to other owners' work.
- Git commit, push, merge, reset, or removal of pre-existing changes.

## 4. ASSUMPTIONS AND OPEN QUESTIONS

### Confirmed requirements

| ID | Type | Description | Status |
|---|---|---|---|
| C1 | REQUIREMENT | UserApp uses TCP ChatServer; AdminApp accesses PostgreSQL through JDBC and has a server control channel for kick requests with acknowledgement and visible notification errors. Plain Java sockets only (D1/D2). | CONFIRMED BY MINH |
| C2 | REQUIREMENT | Application computes BCrypt hashes. Username is 3–30 ASCII letters/digits/underscore, compared case-insensitively for uniqueness/login; email is also case-insensitive (O1). | CONFIRMED BY MINH |
| C3 | REQUIREMENT | Soft deletion uses `deleted_at`, retains profiles and reserves identifiers; deleted/locked accounts cannot log in. Username remains uneditable under the non-conflicting older rule; immutable fields and lifecycle transitions are application responsibilities. | CONFIRMED BY MINH / RETAINED RULE |
| C4 | REQUIREMENT | `login_history` records successful UserApp logins with `user_id`, instant, full-name and username snapshots. One successful login equals one app open; monthly chart counts distinct users per month. AdminApp logins are administration audit events, excluded from activity (O3). | CONFIRMED BY MINH |
| C5 | REQUIREMENT | One active login session; new login kicks old session; online state lives in server memory (D13/D21). | CONFIRMED BY MINH |
| C6 | REQUIREMENT | Ordered friendship pair; reciprocal invite auto-accepts; rejected invitations may be retried unless blocked. Block removes friendship and pending invitations, implements D18 restrictions, and does not interrupt shared group chat. Group additions check block between the adding member and the candidate (D20). | CONFIRMED BY MINH / WORD |
| C7 | REQUIREMENT | Level-two count is distinct users reached through one direct friend, excluding self and all direct friends. | CONFIRMED BY MINH |
| C8 | REQUIREMENT | Shared PRIVATE/GROUP tables; PRIVATE endpoints are stored in `conversations` (S1). Member read pointer, per-message hide and member clear time implement personal state; raw messages remain retained. | CONFIRMED BY MINH |
| C9 | REQUIREMENT | Every group is E2EE from creation, initially creator plus at least two others. Creator is group ADMIN, separate from system ADMIN. Any member may add eligible users; only group ADMIN renames, grants admin or removes members. Last admin selects a successor under O2; when no successor is eligible, Q1=B allows exceptional closure before leaving or soft deletion. Closure stops new messages and preserves data/history within existing access rights. | CONFIRMED BY MINH; Q1 EXCEPTION CONFIRMED 19/11/2026 |
| C10 | REQUIREMENT | New members receive no pre-join keys. Each account has at most one currently authorized E2EE device; switching devices ends the old session, revokes future key receipt by the old device, and gives the new device no earlier keys (O4). Re-login on the same device preserves locally retained keys. No transfer, backup or recovery secrets (Q8=A). | CONFIRMED BY MINH |
| C11 | REQUIREMENT | Text only. PRIVATE plaintext can be searched case-insensitively after visibility filtering; group ciphertext cannot be searched for plaintext in SQL. Group search at the client is deferred. D27 returns message/conversation IDs for jumping; D28 pages 50 messages by message ID. | CONFIRMED BY MINH / WORD |
| C12 | REQUIREMENT | Spam requires an earlier PRIVATE message from the reported user to the reporter. Optional reason; at most one PENDING report per directed pair. D38 says locking moves all reports about that user to RESOLVED; ignoring sets DISMISSED. Do not silently narrow the Word's “all reports” to pending reports only; administration audit preserves the processing trail. | CONFIRMED BY MINH / WORD |
| C13 | REQUIREMENT | D9 password reset generates a random 10-character password, stores its application hash, sends SMTP and reminds the user after login; DB stores the hash and implemented `must_change_password` reminder flag, not plaintext. D10 admin enters a replacement password. No mail or Java implementation here. | RETAINED WORD RULE; APPROVED STORAGE IMPLEMENTED |
| C14 | SCOPE | Use a fresh test database, retain no business triggers/custom functions, and postpone all implementation until this plan is approved. | CONFIRMED BY MINH |

Q1–Q4 below are RESOLVED by Minh's explicit answers on 19/11/2026; original options/recommendations remain as history. Minh subsequently approved the plan and explicitly selected R1=B/R2=A on the same date. Their resolutions derive from those actual answers, not an automatic consequence of plan approval.

### Pre-implementation answer audit (19/11/2026)

| Question | Actual user answer in this conversation | DDL consequence | Audit result |
|---|---|---|---|
| Q1 | Explicit B: exceptional closure stops new messages, preserves authorized history, then permits departure/account soft deletion | Retained records and conversations.closed_at; post-close authorization is application-owned | RESOLVED |
| Q2 | Explicit A | Administration audit/correlation; no outbox table | RESOLVED |
| Q3 | Explicit B; user names membership_periods | Stable member composite PK plus separate period identity/history | RESOLVED |
| Q4 | Explicit A | cleared_at plus scoped cleared_through_message_id | RESOLVED |
| R1 | Explicit reply selecting B | PENDING/ACTIVE/CLOSED epoch shape and activated_at | RESOLVED |
| R2 | Explicit reply selecting A | Versioned opaque bytea public-key/ciphertext/wrapped-key fields | RESOLVED |

O1–O4, Q8-A and S1 were explicit requirements, not unanswered alternatives. Old OPEN wording in iterations 1–2 and prior work-log entries records past state; retain it as history. The cryptographic codec/algorithm is an unimplemented integration dependency, not a missing DDL answer for opaque storage.

### Repository / branch preflight for implementation

Tracked files were clean; only the existing untracked Word source was present. Continue the user's existing `fix/db` work branch (valid fix/ naming family); do not switch to main or disturb other branches. README section 4 asks for pulling/merging main, but Minh's explicit prohibition on automatic merge takes precedence. Read-only local comparison `git rev-list --left-right --count main...HEAD` returned `0 3`, so local main is already an ancestor; no remote-freshness claim is made. No pull/merge/stash/reset/commit/push is authorized or performed.

### Q1 — Last admin removal when no successor is eligible

O2 already requires a successor picker and transfer. A group may later shrink to one member; no minimum membership rule after creation has been specified.

| Option | Behavior and impact |
|---|---|
| A | Block leave/removal/account deletion until an eligible existing member is selected, adding a member first when necessary. Preserves O2 with no new closure lifecycle, but can delay account deletion. |
| B | Add an explicit close-group action for this exceptional case, then allow removal. Avoids an otherwise impossible transfer, but requires a separately approved exception to O2 and closure semantics. |

Original recommendation: **A**, to preserve O2 without a closure exception. **Minh selected B on 19/11/2026. Status: RESOLVED.**

Confirmed exception: when no eligible successor exists, close the group and stop accepting new messages, then permit Minh to leave or soft-delete Minh's account. Closing is not deleting messages: preserve conversation/member records, membership periods, ciphertext, message visibility state and historical wrapped-key grants under existing access rights. It does not grant anyone broader history access, and soft deletion still prevents that account from logging in. If an eligible remaining member exists, keep the normal O2 successor-list/selection/transfer flow. Recheck eligibility and closure under locks; close the current epoch without opening a new one. Group closure and the affected departure/account deletion belong to one DB transaction, including all groups affected by an account deletion. Already closed groups reject new sends, additions and new key grants; historical reads remain subject to the prior membership/device authorization and personal filters.

### Q2 — Persisting JDBC-to-server kick delivery failures

Acknowledgement and visible failure handling are confirmed. A DB commit and TCP delivery cannot be one atomic database transaction.

| Option | Behavior and impact |
|---|---|
| A | Store the admin action and correlation ID/outcome in `admin_audit_log`; attempt the control request after commit, display failure/unknown acknowledgement, and permit idempotent manual retry. Fewer tables; no automatic delivery after an AdminApp crash. |
| B | Also insert an `admin_control_requests` outbox row in the same DB transaction, with request ID, target, state and retry metadata; integration retries until acknowledged. Durable crash recovery, one extra table and worker/retry coordination. |

Original recommendation: **A** for this project's current scope. **Minh selected A on 19/11/2026. Status: RESOLVED.** Store administration audit and correlation/outcome, report control failure or unknown acknowledgement, and allow idempotent manual retry; do not add an outbox or automatic retry worker. Do not report a session as terminated before server acknowledgement. A lost acknowledgement permits retry with the same request ID; account restrictions must be rechecked server-side on protected actions. This plan defines the data contract only.

### Q3 — Membership history and rejoining

| Option | Behavior and impact |
|---|---|
| A | Each `conversation_members` row represents a participation interval with an identity `membership_id`, joined/left times and role; partial uniqueness permits one open interval per conversation/user. Rejoining creates a row and new E2EE boundary. One history table, composite references are larger. |
| B | Keep one `conversation_members` row per conversation/user for current read/clear state and add `membership_periods` for intervals/roles used by messages and grants. Stable personal state across rejoin, but another table and synchronization rules. |

Original recommendation: **A**, keeping intervals in the member table. **Minh selected B on 19/11/2026 and explicitly named the table `membership_periods`. Status: RESOLVED.** Enforce one stable `conversation_members` row per `(conversation_id, user_id)` with UNIQUE; retain that row and its read/clear state after departure. Store each join/leave interval and its group role in `membership_periods`, linked to the stable member; allow at most one open period per member with a partial unique index. Rejoining creates a new period, not another member row, and keeps prior personal hides. Messages identify their sending period; GROUP key grants identify the eligible period and device owner through same-conversation/owner composite FKs. Temporal eligibility and non-overlap remain application transaction checks. Rejoining must not grant keys for pre-join or absence intervals; local possession of an old key does not authorize a new historical grant.

### Q4 — Exact full-clear boundary under concurrent sends

`cleared_at` is confirmed, but timestamp equality, transaction-start timestamps and a delayed commit can otherwise hide a message sent after clearing or reveal one meant to be cleared.

| Option | Behavior and impact |
|---|---|
| A | Store required `cleared_at` plus a `cleared_through_message_id` watermark captured under the conversation lock; sends use the same lock before allocating/inserting message IDs. The ID boundary defines the exact cleared set. One extra member column; deterministic ties and concurrent ordering. |
| B | Use `cleared_at` alone; serialize clear/send under the conversation lock and define a strict server timestamp boundary, including equal timestamps and backwards-clock handling. Fewer columns, more timestamp-ordering logic and tests. |

Original recommendation: **A** for exact “all existing messages” behavior. **Minh selected A on 19/11/2026. Status: RESOLVED.** Store `cleared_at` and `cleared_through_message_id` on the stable `conversation_members` row. Scope the watermark by conversation with a composite FK; NULL means no prior messages. It complements `cleared_at` and does not replace it. Serialize sends/clear under the same conversation lock before message-ID allocation; read pointers never move backwards, and clear/hide never modifies another member's cursor or visibility.

## 5. APPROACH

Steps 1–6 describe the approved overall implementation workflow and iteration 5 delivery. The active iteration 6 is documentation-only; its final-review checks and remaining completion gate are in section 11. It does not authorize a new database run or SQL edit.

### Detailed design questions for this review

| ID | Question and options | Recommendation | Status |
|---|---|---|---|
| R1 | Epoch key readiness: A prepares client-generated wrapped keys before atomically committing the membership/device cutover; B commits the cutover with a PENDING epoch and blocks new sends until a complete eligible-device grant batch activates it. Original options retained for history. | B recommended and explicitly selected by Minh on 19/11/2026; retain epoch_status/activated_at and PENDING default | RESOLVED |
| R2 | E2EE storage format: A versioned opaque bytea envelopes for public keys/ciphertext/wrapped keys; B separate algorithm/nonce/tag/ciphertext columns. Original options retained for history. | A recommended and explicitly selected by Minh on 19/11/2026; codec algorithms/interoperability remain integration work | RESOLVED |

Full options/confirmed choices and dictionary are in baseline section 11. All six decisions are answered and the detailed design is explicitly approved. Iteration 5 authorizes fixtures/queries/tests and isolated DB execution; no choice was inferred from a recommendation.

### Step 1: Review and obtain approval

- **Action:** Preserve iterations 1–4 and existing approvals; reread actual schema/plan/fixtures/rules; identify tools, exact server and a fresh database before execution under iteration 5.
- **Verify:** Only section 6 paths change; old logs/approval history and Word/application remain intact; Git branch/HEAD unchanged; every execution identifies the isolated test target.

### Step 2: Finalize declarative model and responsibility matrix

- **Action:** Document the following 15-table model and FK creation order in the baseline, with ERD, every column/type/null/default, keys/checks/indexes, FK actions and DB/application matrix. Stable member PK is `(conversation_id,user_id)`; `membership_periods.period_id` distinguishes join intervals. The count follows this model, not a legacy constraint. R1=B/R2=A now confirm the documented epoch state and opaque-envelope choices.

| Implemented source table | Purpose and declared constraints; runtime scope in section 9 |
|---|---|
| `users` | Identity, retained required username/email/name/hash, optional profile, system role, registration source, created time, ACTIVE/LOCKED status and independent `deleted_at`; global unique `lower(username)` and `lower(email)`, username format CHECK; proposed reset reminder flag |
| `login_history` | FK to retained user; required successful-login instant and nonblank full-name/username snapshots; contains UserApp successes only by writer contract; optional IP supports existing admin screen without becoming the activity source |
| `admin_audit_log` | Admin authentication and administrative action events with actor, action/target, time, outcome and identity snapshots; confirmed Q2=A records control correlation/outcome and supports manual retry without an outbox. No password, private key or plaintext message body |
| `friend_requests` | Directed users, status and request/resolution times; no self-request; one unordered PENDING pair through a partial unique index; resolved rows retained |
| `friendships` | Ordered user pair PK plus friendship creation time for the existing detail screen; `user_low_id < user_high_id` |
| `user_blocks` | Directed pair PK and no-self CHECK; block removal does not restore old friendship |
| `conversations` | Identity/type/creator/creation and closure metadata; `private_user_low_id/private_user_high_id` required and ordered only for PRIVATE, NULL for GROUP; partial unique pair and local shape CHECKs |
| `conversation_members` | Stable `(conversation_id,user_id)` composite PK; personal read/clear pointers and same-conversation FKs; retained across departures/rejoins by application contract |
| `membership_periods` | Identity for each participation interval, linked to stable member and its conversation/user; joined/left times and period group role; one open period per member via partial unique index; PRIVATE role MEMBER; group role independent of system role |
| `messages` | Retained ID, sender/user/period, time and discriminator; exclusive PRIVATE text or GROUP ciphertext with epoch/device/version; same-conversation/owner/period FKs plus exact sender grant-period FK; confirmed R2=A versioned opaque envelope |
| `message_hidden` | Per-user hide identity linked to a message and stable member/owner in the same conversation; unique message/user; persists across rejoining without deleting shared messages |
| `spam_reports` | Reporter/target FKs, optional reason, status, report time and handler/resolution metadata; no self-report; partial unique directed pair WHERE status=PENDING; local status/time consistency |
| `e2ee_devices` | User/device identity, public key and authorization/revocation times; composite owner key; partial unique user WHERE revoked_at IS NULL |
| `group_key_epochs` | GROUP-scoped epoch, start/end times; partial unique conversation WHERE ends_at IS NULL; confirmed R1=B uses PENDING/ACTIVE/CLOSED and activated_at |
| `group_key_grants` | Epoch/device grant with conversation, membership period, stable member and shared user ID; composite FKs enforce the same GROUP, participation period and device owner; nonempty wrapped key; one grant per epoch/device |

Use a discriminator in composite keys/FKs where needed to bind GROUP-only metadata or PRIVATE/GROUP message shape without querying another table in a CHECK. Create stable members, then `membership_periods`, then dependent messages/grants; add cyclic member read-pointer and clear-watermark FKs after `messages` with `ALTER TABLE`. Creation ordering must not weaken same-conversation validation. A historical period FK proves identity/scope, not current authorization. Q2=A excludes `admin_control_requests` from the implementation inventory; the rejected option remains documented in Q2 only.

- **Verify:** Hand-check FK target uniqueness, all required FK components' nullability and local CHECK null behavior; explicitly reject cross-conversation cursor/hide/epoch and cross-user device grants. Review each index against a query or invariant before adding it.

### Step 3: Document transactions and concurrency before replacing guards

- **Action:** Specify application-side SQL transaction sequences in the baseline, with all decisions and lock order shared by JDBC AdminApp and ChatServer.

| Rule | DB guarantee | Application transaction | Server/client responsibility |
|---|---|---|---|
| Account lifecycle | Required profile/format, global identifier uniqueness, FKs retain referenced identities | Normalize email/username lookup; forbid username/creation-source rewrites and hard deletion; validate active state, set `deleted_at`, retain profile; preserve log snapshots | BCrypt, reset mail/reminder and authenticated actor; stop revoked/locked/deleted sessions |
| Login and activity | Required history fields and user FK | Insert one UserApp success with snapshots per completed authentication; AdminApp writes audit instead; coordinate per-account device change | Serialize login replacement; publish online state; no app-open event on reconnect without a new successful login |
| Reciprocal invite / block / private send | Ordered/unique pairs and at most one pending request | Lock existing `users` rows for both endpoints in ascending ID order before checking/writing, including when no social row exists; recheck status/block, auto-accept reciprocal request or write one pending request; block cleanup is atomic | Caller permissions, D18 asymmetric search exclusion and two-way PRIVATE-send restriction |
| PRIVATE pair and members | Conversation ordered endpoints, pair uniqueness, stable member uniqueness and period FKs | Create exactly the two endpoint member rows and their initial periods with the pair; prevent third-party PRIVATE members or endpoint changes; group cardinality is not a CHECK | Authenticate sender; shared history may still be viewed subject to personal visibility |
| Group roles, size and exceptional closure | Role domain, stable member uniqueness, one open period per member, same-conversation FKs, closure timestamp shape | Lock group row, require at least three distinct eligible initial members and creator ADMIN; any active member may add subject to D20; only ADMIN renames/grants/removes; transfer O2 successor before removal when eligible, otherwise close under Q1=B before leave/soft deletion; retain records and close the current epoch | Show successor list normally; show closure outcome for the confirmed exception; system ADMIN is not automatically group ADMIN; stop delivery of new group messages after closure |
| Send / read / hide / clear | Message shape, membership identity, same-conversation references, duplicate-hide prevention | Lock conversation for the chosen ordering contract; check current membership, current epoch/device as applicable; apply Q4; monotonic cursor updates and personal filters | Supply identity from session; server stamps time; client renders local visibility and pagination |
| Spam / account lock | Directed PENDING uniqueness and valid status/times | Check a retained incoming PRIVATE message regardless of hides/clear; lock target before report creation/processing; lock action updates account and all target reports to RESOLVED per D38; ignore sets DISMISSED; audit transition | Group-only messages do not qualify; show processing error or control delivery outcome truthfully |
| E2EE join/remove/device switch | At most one current device and epoch; FK period/owner/group scope | Revoke old device, close affected epochs and open new epochs on membership/device authorization changes in open groups only; eligibility begins no earlier than the current participation period/device authorization; deny stale grants/sends; never reopen a closed group or its epoch as a side effect | Client holds private/plain group keys; server routes opaque envelopes only to eligible current device; new member/device receives no history keys; same-device re-login preserves local keys |

Use `READ COMMITTED` with explicit existing-row locks and fresh checks after waiting, rather than retaining `lock_social_pair` or replacing it with another custom function. The detailed global order is users in ascending ID, then affected conversations in ascending ID, then dependent membership/device/epoch/report rows. If an operation discovers another endpoint or group after locking, restart with the complete sorted set; do not acquire earlier locks late. Use bounded retries for deadlock/serialization/unique conflicts where the operation is safe to retry. Message-send and group/device changes must share this protocol; group changes cannot rotate epochs while a competing send commits against stale eligibility.

DB constraints alone cannot enforce current membership, exact member count, block absence, role authority, monotonic read state, immutable historical records, last-admin transfer, non-overlapping closed intervals or “no historic keys.” Direct ad hoc SQL can violate these business rules. Document this limitation; SQL transaction demonstrations do not prove that unimplemented applications obey the contract.

- **Verify:** Review each former trigger's rule against this matrix; simulate reciprocal invites, block/send, concurrent last-admin removal, close/send and device-switch/send in two psql sessions, confirming either serialized success or rollback with no partial state. Verify closure preserves prior data/access boundaries and rejects new writes. Actual TCP delivery and cryptographic access remain integration checks.

### Step 4: Replace schema and fixtures on a fresh test database

- **Action:** Keep approved DDL unchanged except factual comments; replace old seed/assertions and add parameterized queries/negative-case documentation. Use deterministic explicit fixture IDs, fake labelled bytes and Vietnam time boundaries. Create a uniquely named empty test DB, then execute schema→seed→queries→verify.
- **Verify:** PASS on the target below: actual parser/catalog/constraint checks A=48, actual query assertions B=40 and rollback-only writer simulations C=11. Compare complete table/sequence fingerprints after rollback. No old trigger expectation or helper function remains; real integration is D NOT RUN.

### Step 5: Verify reports and visibility

- **Action:** Add SQL assertions for Admin filters/sorts and activity aggregation; count sent PRIVATE counterpart IDs and GROUP conversation IDs distinctly, independently of personal hide/clear state. Use login successes for app-open totals and distinct users for monthly activity; keep AdminApp audit excluded. Keep self-registration separate from admin-created accounts in registration reports. Propose an active-list population of users with a UserApp success in the selected period under O3; send counts are separate columns. Show zero-count months with a 12-month series.
- **Verify:** Use fixtures with two paths to the same second-level user, a triangle, an isolated user, several logins in one month, logins in adjacent months, an AdminApp-only login, deleted historical users and messages hidden by one member. Assert exact expected results and half-open Vietnam-local day/month boundaries. Search/jump/page queries exclude hidden/cleared/ineligible history; do not execute plaintext matching on GROUP ciphertext. Query identity and sort tie-breakers remain stable.

### Step 6: Document actual delivery and report limitations

- **Action:** Synchronize baseline and existing database-schema.md with actual SQL, target identity and A/B/C/D results using the feature-template structure. Mark IN_PROGRESS; record remaining concurrency/application integration as NOT RUN. Preserve historical log entries/iterations and approval evidence.
- **Verify:** Compare every table/FK in the ERD to catalog output, report each criterion below truthfully, and leave server/JDBC/client/crypto checks NOT RUN until separately exercised. Do not declare the full system implemented from database tests alone.

### Alternatives considered

- Keeping separate private/group message tables contradicts the confirmed shared model; S1 is accepted and is not reopened as a choice.
- Keeping triggers or recreating their logic in custom functions violates Minh's constraints. Application transactions make the resulting responsibility explicit.
- Reusing `app_open_events` as a second activity source risks double counting and violates the chosen UserApp login definition.
- A server-held master group key or normal-group toggle conflicts with mandatory E2EE. Store only public keys, wrapped group keys and ciphertext; no server decryption capability is proposed.

## 6. FILES TO CREATE / MODIFY

This table describes delivered files and the current change boundary. Iteration 5 added the requested query/negative-case paths before implementation. Iteration 6 edits only the four documentation paths marked MODIFY; all SQL/tests and external handoff sources are read-only. No DDL, database, application or Git mutation is required for this review.

| Action | File path | Timing and purpose |
|---|---|---|
| MODIFY | `docs/ai/database-schema/plan.md` | THIS SESSION: preserve approvals/iterations 1–5; iteration 6 final review, current scope/evidence/gates and exact requested commit message |
| MODIFY | `docs/ai/work-log.md` | THIS SESSION AND LATER: append action/session entries; add/update only the matching progress row |
| READ ONLY | `script/schema.sql` | Approved 15-table DDL, previously executed in the identified fresh test DB |
| READ ONLY | `script/seed.sql` | Deterministic DB-only fixtures and aligned identity sequences, delivered in iteration 5 |
| READ ONLY | `script/queries.sql` | Nine parameterized session PREPAREs; canonical history/search/page/around visibility, delivered in iteration 5 |
| READ ONLY | `script/tests/verify.sql` | A/B/C isolated SQL checks and D NOT RUN reporting, delivered/executed in iteration 5 |
| READ ONLY | `script/tests/negative-cases.md` | Exact case expectations, target and prior results, delivered in iteration 5 |
| MODIFY | `docs/database/design-baseline.md` | THIS SESSION: preserve model/dictionary, add final decision coverage and evidence/gate distinctions |
| MODIFY | `docs/ai/database-schema/database-schema.md` | THIS SESSION: factual delivered files/schema/run/test/limits plus read-only README/use-case/UI handoff |

Read-only sources, including the Word document, templates, UI plans/docs, requirements specification and project brief, remain unchanged.

## 7. DEPENDENCIES

### Libraries / frameworks

- PostgreSQL/psql **17.11**, actual server_version_num **170011**. Existing Docker chat-postgres a0786fdd6fe1 publishes 127.0.0.1:5432; transport used container Unix socket /var/run/postgresql:5432.
- Host psql/createdb were absent; Docker and container psql were available. No installation/download/container creation was needed. Role chat_user can create databases; a new TEMPLATE template0 test DB was created after read-only metadata checks on maintenance postgres. Business chat_system was not queried.
- No new DB extensions or runtime libraries are planned. BCrypt/jBCrypt stays in application code; the schema stores its output.

### Depends on other features

- `auth`, `socket-server`, `socket-client`: correct successful-login capture, in-memory session replacement, protected-action checks and control request acknowledgement.
- `group-encryption`: client device identity, local key retention, wrapped-key/ciphertext envelope format and epoch transitions. This feature can test storage/ownership, not actual confidentiality or decryption.
- `admin-user-mgmt`, `spam-report`, `friend-system`, `chat-1-1`, `group-chat`, `admin-stats`: consumers must implement the documented transactions; current UI samples do not provide those guarantees.
- UI owners must later align obsolete sample assumptions (IP/history fields, normal-group indicators, minimum group size and statistics labels). Coordinate findings without editing their Java/FXML/CSS in this feature.

### Technical constraint check

- [x] Networking architecture is plain `java.net.Socket` / `java.net.ServerSocket`; no networking implementation is part of this database feature.
- [x] This plan introduces no WebSocket API/library, custom DB business function, stored procedure or business trigger.
- [x] Admin JDBC and server/client responsibility boundaries are explicit; the DB is not claimed to know socket online state or plaintext group messages.

## 8. RISKS

| Risk | Severity | Planned mitigation |
|---|---|---|
| JDBC AdminApp or server bypasses application checks after trigger removal | HIGH | Publish one shared transaction/lock contract and its direct-SQL limitation; require integration verification by consuming owners |
| Last-admin account deletion spans multiple groups or no eligible successor exists | HIGH | Apply confirmed Q1=B: transfer when eligible, otherwise close exceptionally before departure/deletion in the same transaction; preserve prior data/access; recheck or rollback stale choices |
| New device receives an old epoch key, or old device keeps receiving new keys | HIGH | Preserve O4 partial uniqueness; coordinate account/session revocation and all affected group epochs; test SQL eligibility and separately test routing/crypto |
| Already-delivered keys cannot be erased from an old device | HIGH | Revoke future delivery and rotate epochs; make no claim that DB revocation erases local data |
| Deadlocks or a nonexistent social-pair row defeats locking | HIGH | Lock existing users before social checks, enforce sorted user/group order, and demonstrate competing writes in two sessions |
| DB commit succeeds but TCP kick fails or acknowledgement is lost | HIGH | Apply Q2=A: audit correlation/outcome, visible unknown/failure state and idempotent manual retry; no outbox; never label unacknowledged control delivery successful |
| Clear/read state exposes history on rejoin or loses a new message at the boundary | HIGH | Apply Q3=B/Q4=A: stable member state, separate membership_periods and a scoped clear watermark; test clear/send, ties and rejoin without back-grants |
| Old fixtures/tests pass while validating the wrong rules | HIGH | Replace semantic expectations, remove exact 16-table assertion and trigger helper dependencies; never carry historical PASS forward |
| D38 updates a previously DISMISSED report when the user is subsequently locked | MEDIUM | Follow the Word's all-report rule; record prior processing through audit events rather than silently implementing pending-only resolution |
| Retained identifiers/profile conflict with old anonymization and reuse expectations | MEDIUM | Global case-insensitive indexes include deleted accounts; test rejection of reuse and preserved snapshots |
| Broad queries create duplicate friend/activity counts | MEDIUM | Deduplicate IDs at the correct level; test multiple paths, repeat logins, Admin-only events and Vietnam month boundaries |
| History sorting/search assumptions differ across stale documents | MEDIUM | Keep D27/D28 ID pagination; use case-insensitive PRIVATE text search, scoped personal filters and no GROUP plaintext SQL search; inspect index plans after representative seed data |

## 9. SUCCESS CRITERIA AND VERIFICATION

### Planning checks

These verify the documentation session only, not the future implementation. Final results are recorded in the session-end work-log entries after checks run.

P1–P4, D1–D4 and S1–S4 retain earlier planning/design/source-session results. Their prior file scopes and NOT RUN states describe those sessions. Current iteration 5 execution evidence follows separately; no prior runtime PASS is reused.

| ID | Criterion | Verification | Result |
|---|---|---|---|
| P1 | Correct repository and pre-existing changes identified | `git rev-parse --show-toplevel`, branch/origin and initial `git status --short`; source list review | PASS |
| P2 | Requested sources, including Word content, are readable and reviewed | Read all listed Markdown/SQL files and extracted Word body/table text; document priority/conflicts above | PASS |
| P3 | Complete plan; approval remains NO; only two authorized documentation paths change | Final `git status`, `git diff --check`, plan section/placeholder check and work-log preservation comparison | PASS |
| P4 | Session boundaries, action types, timestamps and progress row follow work-log rules | Compare historical entries to HEAD; validate new lines against section 2 types and actual Vietnam clock; verify end entry and tracker | PASS |

| ID | Prior detailed-design criterion | How verified in that phase | Result |
|---|---|---|---|
| D1 | Actual approval and choices recorded without inferred answers | IN_PROGRESS / YES (19/11/2026); Q1–Q4 and R1=B/R2=A RESOLVED by explicit user messages; no further named decision auto-resolved | PASS |
| D2 | Detailed baseline is internally consistent and explicitly IN_REVIEW | Static review: 15 dictionaries/109 columns, 33 type-matched FKs and ERD edges, six UNIQUE targets, 36 index definitions, local null rules/actions/creation order; Mermaid visual rendering NOT RUN | PASS |
| D3 | Changes remain within the three authorized documents | Git diff/status and unchanged SQL/tests/Word hashes; no application changes or implementation feature document | PASS |
| D4 | Prior logs and iteration history survive; progress is truthful | Pre-session log/tracker preserved except session append and added phase note; iteration 1 intact, truthful tracker and session boundaries | PASS |

### Prior iteration 4 schema-source review (not database tests)

| ID | Source criterion | Method / limit | Result |
|---|---|---|---|
| S1 | Actual design approval and all historical OPEN questions audited | Explicit Q1=B/Q2=A/Q3=B/Q4=A/R1=B/R2=A messages plus current design approval; historical OPEN text retained; no unanswered DDL choice | PASS |
| S2 | DDL source agrees with dictionary/keys/FKs/indexes | Inline Node source checker: 15 tables/109 column types/null/defaults, 15 PKs/6 UNIQUE/33 FKs/46 CHECKs/36 exact index definitions; parent order, scoped targets/actions, local CHECK identifiers, names and duplicate-index review; not PostgreSQL parser/runtime validation | PASS |
| S3 | Only authorized files changed and protected work preserved | Five-path Git scope; unchanged seed/test/Word SHA256 and branch/HEAD; append-only historical log/iteration comparison | PASS |
| S4 | Feature documentation and progress reflect partial implementation | Seven feature-template sections based on actual source; IN_PROGRESS, Code ongoing, Doc present; eleven runtime criteria NOT RUN; truthful logs/tracker | PASS |

### Iteration 5 execution and acceptance evidence

Actual target: **jcs_schema_test_20261119_120407_2ed14e**, owner chat_user, on existing chat-postgres **a0786fdd6fe1**, published **127.0.0.1:5432**. PostgreSQL/psql 17.11, version_num170011. Execution used container Unix socket **/var/run/postgresql:5432**; host TCP was not tested. The new TEMPLATE template0 database had zero public tables before schema. No business database, extension installation, database/schema deletion or application edit was involved.

schema→seed→nine PREPAREs→verify succeeded. verify.sql reports **A=48 PASS, B=40 PASS, C=11 PASS SQL simulations, D=1 NOT RUN**. A errors are per-case subtransactions; C has per-case savepoints, outer verification ROLLBACK and complete 15-table/identity-sequence fingerprint equality. Exact case IDs, expected SQLSTATE/constraint or ordered results and repeat commands are in [negative-cases.md](../../../script/tests/negative-cases.md). Schema/seed are run-once; do not rerun them on the populated target. New full runs require a new uniquely named empty test DB, without dropping previous databases.

| ID | Criterion | Actual evidence / remaining limits | Result |
|---|---|---|---|
| V1 | Fresh schema/seed/tests succeed with approved inventory and no prohibited DB code | Actual execution plus A00 catalog inventory, restrictive FKs, no custom public function/procedure/non-internal trigger/unapproved extension | PASS |
| V2 | Identity validation and retained deletion match C2/C3 | A01–A07/A39/A47, B32/B40 cover CI uniqueness, deleted identifier reservation, short/dot/NULL usernames and retained snapshots/profile. Long/non-ASCII input and real lifecycle writers not exercised | PARTIAL; remaining runtime cases NOT RUN |
| V3 | Login snapshots and statistics distinguish applications | B32–B35/B39: historical name, six November logins/four distinct users, month endpoints, AdminApp exclusion; writer authentication remains D | PASS for stored-event/query contract |
| V4 | PRIVATE identity/payload and cross-scope constraints hold | A12–A20/A26–A31/A35–A38/A42/A46; seed has exactly two canonical members per PRIVATE. C07 proves extra child rows need application rejection. Inverted PRIVATE endpoint runtime case not separately exercised | PARTIAL; application writer NOT RUN |
| V5 | Social transactions preserve invitation/block rules | Seed retry history; A11 pending uniqueness; C01–C03 explicit reverse acceptance/block cleanup | PARTIAL; block/send and reverse-invite committed races NOT RUN |
| V6 | Personal state/rejoin and exact clear boundary | A17–A21/A36/A45; B01–B30/B38/B40 show stable rejoin state, personal hide/clear, pagination/search and period/device visibility | PARTIAL; empty-clear, monotonic update, timestamp-tie and concurrent clear/send writers NOT RUN |
| V7 | Group size/roles/transfer/exceptional closure | Initial GROUP cardinality checked; C04/C10/C11 demonstrate transfer, role/minimum predicates, exceptional closure/retention; B17/B38 retain closed history | PARTIAL; full add/remove writers and competing last-admin/close-send committed races NOT RUN |
| V8 | E2EE metadata and O4/Q8 eligibility | A23–A31/A44/A46 and B11–B17/B25/B30; C05/C09 device rotation/PENDING visibility and deliberate unsafe-send boundary | PARTIAL; committed cutover/send races, complete activation batch and real device/crypto integration NOT RUN |
| V9 | Directed spam eligibility/processing D37/D38 | A32–A34, B36, C06/C08; all fixture reports have incoming PRIVATE evidence, opposite-direction PENDING allowed, all target statuses resolve on SQL lock demo | PARTIAL; group-only incoming rejection and production processing/ignore writers NOT RUN |
| V10 | Reports/search accurate and scoped | B01–B40: only-level-two distinct graph, sent-target/group counts, self-registration, 12 months, explicit Vietnam dates, visible PRIVATE search/page/around; '%' literal/accent cases | PASS for tested query contract |
| V11 | Catalog/source/ERD/index/docs evidence agrees | A00 actual inventory corroborates prior source mapping; EXPLAIN ANALYZE/BUFFERS executed for group history, friend counts and monthly activity. Small-fixture plans do not prove production performance; Mermaid visual rendering NOT RUN | PASS for inventory/representative plan review |

**Concurrency status: NOT RUN.** verify.sql is a single-connection rollback-safe suite, not a two-session committed writer harness. The pending races and protocol are specified in negative-cases.md and baseline section 10; they remain acceptance work rather than being inferred from a sequential simulation. Full feature status stays IN_PROGRESS and Verified stays in progress, since not every V criterion has passed completely.

### Integration checks outside this database implementation

Actual JDBC writes, UserApp session replacement, immediate kick acknowledgement/error UI, single-device delivery after O4 switching, real client decryption, same-device local key retention, and client group search are **NOT RUN**. Database SQL simulations do not validate them. The first integration handoff must exercise two real sessions/devices, locked-account control failure/retry, and membership/device epoch changes before the full application can claim these behaviors. Client group search remains explicitly deferred.

## 10. ITERATION LOG

## [ITERATION 1 - 19/11]

**Reason for change:** Minh explicitly answered Q1=B, Q2=A, Q3=B with the table name `membership_periods`, and Q4=A on 19/11/2026. This is a controlled plan revision before implementation; no overall coding approval is recorded.

**Old approach:** The initial plan recommended A for all four questions, left them OPEN, kept participation intervals inside `conversation_members`, and proposed blocking last-admin removal when no eligible successor existed. It listed an optional outbox and optional `conversation_membership_periods` table.

**New approach:** Q1–Q4 are RESOLVED as B/A/B/A. Exceptionally close the group before last-admin departure/soft deletion when no successor is eligible; stop new messages while preserving data and existing history access. Use audit/manual retry without an outbox. Keep one stable member row per conversation/user, separate intervals into `membership_periods`, and retain `cleared_at` plus the message-ID watermark on the stable row.

**Impact:** Updated sections 1–5 and 8–9, candidate tables, dependency order, period-based message/grant FKs, closure transaction and V6/V7 criteria; no expansion of the file boundary in section 6. Only this plan and append-only work-log entries change in this session. Existing recommendations/options and earlier log records remain available as history. All V1–V11 implementation checks stay NOT RUN; the progress row remains Plan complete with other columns not started. Overall status remains AWAITING_APPROVAL and plan approval remains NO pending explicit implementation approval.

## [ITERATION 2 - 19/11]

**Reason for change:** Minh explicitly approved the agreed plan and requested a detailed design review before any SQL changes. This approval persists across the interrupted turn. Elaborating E2EE cutover and storage exposes new R1/R2 decisions; they are not answered by previous approvals.

**Old approach:** Plan remained AWAITING_APPROVAL / NO after recording Q1–Q4. The baseline was scheduled for later implementation documentation and still described the old trigger-based split schema.

**New approach:** Record YES (19/11/2026) and IN_PROGRESS for the actual approved plan, with detailed-baseline review as the active phase. Replace obsolete baseline descriptions with a concrete 15-table working proposal, stable composite member PK, separate participation-period identities, composite FK catalog, FK actions, indexes, creation order, responsibilities and review options. R1=B/PENDING epochs and R2=A/opaque versioned envelopes are explicitly recommendations only; both questions stay OPEN until Minh answers.

**Impact:** Same file boundary: baseline, plan and work-log now; SQL/seed/tests/application untouched. Added design checks D1–D4; implementation checks V1–V11 remain NOT RUN. No new approval is inferred for R1/R2, no existing Q1–Q4 answer is reopened, and iteration 1 remains intact. No implementation feature document is created before implementation.

## [ITERATION 3 - 19/11]

**Reason for change:** Minh explicitly replied “oke R1 B, R2 A” on 19/11/2026. These actual answers resolve the two detailed-design questions.

**Old approach:** Iteration 2 left R1/R2 OPEN and labeled PENDING epochs/versioned opaque envelopes as recommendations only.

**New approach:** Record R1=B and R2=A as RESOLVED. Keep PENDING/ACTIVE/CLOSED epoch status, activated_at and send blocking until batch activation; use versioned opaque bytea public-key/ciphertext/wrapped-key envelopes. Preserve original alternatives and prior iteration history. Actual crypto codec/algorithms remain an integration dependency, not an unanswered storage-choice question.

**Impact:** Plan/baseline/work-log updates only; no change to the 15-table dictionary, keys or indexes and no SQL/test/application edits. All named Q1–Q4/R1–R2 decisions are answered; V1–V11 remain NOT RUN. Plan stays IN_PROGRESS / YES (19/11/2026); no additional approval question is introduced by this record.

## [ITERATION 4 - 19/11]

**Reason for change:** Minh explicitly approves the detailed design and authorizes updating schema.sql plus factual in-progress documentation, while prohibiting SQL execution/application changes/commit/push. Audit found no unanswered DDL-affecting named choice; all six answers are explicit.

**Old approach:** Decision-recording phase updated three documents only; source SQL still used old split tables/custom guards. Fixtures and runtime acceptance had not begun.

**New approach:** Implement approved DDL source and synchronize baseline/plan/work-log; create the requested feature document with IN_PROGRESS and runtime NOT RUN. Keep seed.sql/verify.sql untouched and identify them as stale/incompatible. Perform static source checks of dictionary, keys/FKs, NULL shapes, creation order and duplicate indexes without connecting to PostgreSQL.

**Impact:** Five existing planned paths are active this turn; no new file outside the boundary. Keep plan IN_PROGRESS / YES, code progress in progress, feature doc present, runtime Verified not complete and Committed unconfirmed. Preserve previous iterations and historical logs. README pull/merge workflow yields to Minh's no-auto-merge instruction; keep fix/db and HEAD unchanged.

## [ITERATION 5 - 19/11]

**Reason for change:** Minh explicitly requests seed, parameterized queries, executable verification and negative-case documentation, plus runtime execution only in a clearly identified fresh test database. Existing old fixtures/assertions are incompatible and must be replaced.

**Old approach:** Schema source was written/static-reviewed only; seed/query/runtime work had not begun and V1–V11 remained NOT RUN.

**New approach:** Add queries.sql and negative-cases.md to the boundary before editing. Use deterministic explicit fixture IDs with built-in sequence alignment, fake password/key/cipher bytes labeled DB fixtures, one canonical prepared history/visibility query for all navigation modes, and explicit expected results. A failures run in per-case anonymous-block subtransactions with exact SQLSTATE/constraint assertions and no helper function/trigger; B runs the actual prepared queries; C simulates and rolls back SQL transaction contracts without claiming application implementation; D remains NOT RUN until real integration is exercised.

**Impact:** Docker/psql 17.11 are available in existing chat-postgres (published host 127.0.0.1, port 5432). Role chat_user has create-DB permission, confirmed through maintenance postgres only. Create a fresh uniquely named jcs_schema_test_* database and record exact name/owner/server/version before schema→seed→queries/verification. Do not use chat_system, install tools, delete a DB/schema or change an important DDL decision without approval. Update baseline/plan/feature/log from actual results. schema.sql may receive truthful header comments; preserve approved DDL unless a necessary scoped fix is found.

## [ITERATION 6 - 19/11]

**Reason for change:** Minh requests a final evidence-based review and completion of four documents, with no unnecessary repetition of unchanged passing SQL tests and no edits to external README/use-case/UI handoff files.

**Old approach:** Iteration 5 implemented/executed fixtures/queries/tests; documents described that delivery session and recorded partial V criteria, without a consolidated final decision/handoff review.

**New approach:** Review the actual Word body, explicit overriding answers, source/constraints/FKs, fixture/query/assertion code and Git diff of the implementation. Map every confirmed choice to DB storage or an application obligation. Trace A48/B40/C11 to the new-schema session rather than old-schema/UI results. Preserve IN_PROGRESS because V2/V4–V9 have unexecuted in-scope cases; classify real D integration as downstream NOT RUN. Update current documentation and provide a concrete external handoff list, preserving iterations 1–5 and all approvals/history.

**Impact:** Only plan.md, database-schema.md, design-baseline.md and work-log.md/tracker are editable. Current fix/db HEAD is 2971bb46f93ba7fbc51b9cedd8cf56f0ab2b7254; tracked files were clean and the existing untracked Word file remains protected. No SQL/test/application changes, DB connection or test rerun. No new DDL-affecting decision was found. The requested future commit message is feat(database-schema): redesign PostgreSQL schema for approved decisions; no automatic commit/push/merge.

## 11. FINAL RESULT

| Field | Value |
|---|---|
| Completion date | Not completed; final documentation review recorded 19/11/2026, required database acceptance remains incomplete |
| Commit message requested by Minh | `feat(database-schema): redesign PostgreSQL schema for approved decisions` |
| Current result | Fresh test DB executed schema/seed/queries/verify: A48/B40/C11 SQL simulations PASS; D integration NOT RUN. Catalog15/109/15/6/33/46/57 total indexes; DDL unchanged except factual comments; rollback preserves all rows/sequences |
| Feature description | Existing database-schema.md describes delivered SQL, target/results, DB guarantees versus writer obligations, incomplete acceptance and external README/use-case/UI handoff |

Implementation checkpoint: decisions/approval remain unchanged; iteration 5's four requested artifacts and isolated A/B/C SQL execution are delivered. Remaining V cases, two-session committed races and D integration require further verification; no full feature completion, real login or working E2EE claim. No commit/push/merge/reset performed.

### Final review outcome and completion gate (iteration 6)

| Review | Evidence and outcome |
|---|---|
| Scope/other work | git diff aaaffba..2971bb4 covers exactly the nine approved implementation/doc paths; current tracked worktree initially clean. This review changes only four docs. Word/SQL/test/application/README/use-case/UI sources remain unchanged |
| Decision coverage | Baseline section 13 maps C1–C14, Q1–Q4, R1–R2, O1–O4, Q8-A and S1 to actual objects/consumer contracts; no unresolved named DDL choice or unapproved important redesign found |
| Declarative boundary | 15 tables/109 columns; source has no CREATE FUNCTION/PROCEDURE/TRIGGER/EXTENSION or cross-table CHECK. Scoped FKs prove correspondence, not current permission or cryptographic validity |
| Evidence freshness | New-model execution logged 19/11/2026 12:25 and 12:36, exact target and A/B/C case IDs preserved; no 08/11 old-model result or UI PASS reused. No SQL changed during this review, so no runtime rerun |
| Documentation | Factual seven-section feature doc; no unfilled placeholder/template directions; concrete handoff and remaining checks documented |
| Status | IN_PROGRESS; Plan/Code/Doc complete, Verified in progress, Committed unconfirmed by user. Visible Git commits do not substitute for the tracker rule requiring user confirmation |

**Required in-scope work before DONE:** finish V2/V4 input/pair boundary cases; V5–V8 committed two-session lock/recheck races; V6 empty-clear/monotonic/tied-time writer cases; V7 full group add/remove/closure contracts; V8 complete eligible activation batch/no-back-grant/send contracts; V9 group-only spam rejection/ignore transition contracts. Exercise these only in an explicitly identified isolated test environment, retain exact outcomes, and rerun affected checks after fixes. Do not convert PARTIAL/NOT RUN to PASS through this documentation review or weaken criteria to claim completion.

**Downstream handoff:** real BCrypt/JDBC/TCP sessions/control acknowledgements/device proof/client crypto remain D NOT RUN and outside the SQL implementation. Their future completion is separate from finishing the in-scope database acceptance above. Client group search is expressly deferred. See feature section 7 for exact README/use-case/UI locations and server/AdminApp/UserApp ownership. No additional design selection is requested by this review.
