# PLAN — database-schema

| Field | Value |
|---|---|
| Feature name | `database-schema` |
| Created | 19/11/2026 |
| Owner(s) | Minh |
| Status | `IN_PROGRESS` |
| Plan approved by user | YES (19/11/2026) |
| Design decisions | Q1=B, Q2=A, Q3=B (`membership_periods`), Q4=A; confirmed by Minh on 19/11/2026 |
| Session scope | Detailed design review: baseline, plan and work-log only; SQL/tests/application changes are not authorized in this session |
| Current review gate | Detailed design R1/R2 remain OPEN; obtain Minh's selection and baseline approval before SQL |
| Time zone | `Asia/Ho_Chi_Minh`; date obtained from the live clock, UTC+07:00 |

## 1. SUMMARY

Redesign the PostgreSQL schema for the confirmed JAVA CHAT SYSTEM requirements, replacing the existing trigger-based, separate private/group model with declarative constraints and a shared conversation model. Preserve account identities and history, support UserApp-only activity statistics, and store E2EE metadata without implementing cryptography. Minh approved this plan on 19/11/2026 after resolving Q1–Q4 as B/A/B/A. The current authorized phase is detailed design in `docs/database/design-baseline.md`; its new R1/R2 questions and baseline review must be settled before SQL is written.

### Repository and source review

- Repository: `D:\java-chat-system`, branch `fix/db`, origin `git@github.com:PandMin426/java-chat-system.git`.
- Initial `git status --short`: only `?? docs/Phuong_an_da_chot_JAVA_CHAT_SYSTEM.docx`. This pre-existing source must remain unchanged and untracked unless Minh acts separately. No tracked modifications were present.
- No `AGENTS.md` was found in the repository or its drive-root ancestor. `.agent/rules/rule.md` is the applicable local workflow. Its `docs/ai/templates/` reference is stale; use the actual `docs/ai/_template/` files, as explicitly requested, without renaming them.
- No existing `docs/ai/database-schema/` feature or approval history was found. This is its initial plan.
- Read both `_template` files; the `ui-admin-screens` plan and feature document; all of `docs/ai/work-log.md`; `script/schema.sql`, `script/seed.sql`, `script/tests/verify.sql`; `docs/database/design-baseline.md`; `docs/Final_Project_He_Thong_Chat_Chi_Tiet.md`; and `docs/ai/requirements-analysis/use-case-specification.md`.
- Successfully read `docs/Phuong_an_da_chot_JAVA_CHAT_SYSTEM.docx` through its OOXML document body, including table-cell text (152 paragraphs). The Word source is available; no missing-source assumption is needed. This was a content review, not a Word layout audit. Its decision numbering omits D40; do not invent a D40 decision.
- Source priority: Minh's explicit decisions in this request, including O1–O4, Q8=A and S1, override conflicting Word and older documents. Use the Word decisions for other business rules. Older SQL, baseline and use cases describe the current implementation or historical choices, not approval for this redesign. UI documents describe sample screens, not implemented JDBC/server behavior.

### Differences from the current database

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
- Minh's plan approval, explicitly received on 19/11/2026, and confirmed Q1–Q4 answers B/A/B/A. Detailed E2EE design selections R1/R2 remain OPEN; approval of the plan does not authorize this session to write SQL.

### Output / Expected result

- This session: approved-plan metadata, a detailed baseline marked IN_REVIEW, preserved iteration history and append-only log entries; review the existing progress row without claiming code or implementation verification complete.
- After approval: coherent schema, seed, verification script, updated baseline/ERD and implementation feature document, all matching the approved decisions.
- An explicit allocation of every rule to declarative DB enforcement, application transaction, or server/client integration, with reproducible evidence and remaining integration checks reported truthfully.

## 3. SCOPE

### In scope

- Accounts, retained soft deletion, password metadata, successful UserApp login snapshots, administration audit, social relationships, unified text messaging, stable per-user conversation state plus `membership_periods`, group roles and exceptional closure, spam processing, reporting queries and E2EE storage metadata.
- Fresh-database DDL using tables, identity, PK, FK, NOT NULL, UNIQUE, row-local CHECK, DEFAULT, indexes and justified partial unique indexes. Built-in expressions such as `lower` are permitted; no cross-table CHECK.
- Foreign keys that bind a message/read pointer/hide/grant to the correct conversation and a grant to the correct device owner.
- Application transaction contracts, lock order, rollback and retry rules, including races between block/send, reciprocal invites, admin transfer, and device/epoch changes. SQL simulations test these contracts without adding Java code.
- Query examples for Admin screens S11–S17 and User history/search; UTC instants stored as `timestamptz`, reporting boundaries explicitly in `Asia/Ho_Chi_Minh`.

### Out of scope

- This session: changing SQL, executing schema/seed/tests, creating `database-schema.md`, or revising documents outside the baseline, this plan and work-log.
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
| C13 | REQUIREMENT | D9 password reset generates a random 10-character password, stores its application hash, sends SMTP and reminds the user after login; DB stores the hash and a proposed `must_change_password` reminder flag, not plaintext. D10 admin enters a replacement password. No mail or Java implementation here. | RETAINED WORD RULE; COLUMN DESIGN PROPOSED |
| C14 | SCOPE | Use a fresh test database, retain no business triggers/custom functions, and postpone all implementation until this plan is approved. | CONFIRMED BY MINH |

Q1–Q4 below are RESOLVED by Minh's explicit answers on 19/11/2026; original options/recommendations remain as history. Minh subsequently explicitly approved the plan on the same date. Detailed design questions R1/R2 below are separate, newly identified items; neither has been answered, and neither is auto-resolved by the earlier approval.

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

### Detailed design questions for this review

| ID | Question and options | Recommendation | Status |
|---|---|---|---|
| R1 | Epoch key readiness: A prepares client-generated wrapped keys before atomically committing the membership/device cutover (fewer states, but can delay the action when no client is ready); B commits the cutover with a PENDING epoch and blocks new group sends until a complete eligible-device grant batch activates it (extra status/activation fields, separates action from client availability). | B; dictionary shows this working proposal explicitly, not an approved choice | OPEN |
| R2 | E2EE storage format: A versioned opaque bytea envelopes for public keys, ciphertext and wrapped keys (algorithm-independent DB, clients validate codec); B separate algorithm/nonce/tag/ciphertext columns (more SQL-visible structure, must first settle the crypto format and lengths). | A; no cryptographic algorithm is implemented or approved by this storage proposal | OPEN |

Full options, impacts and the provisional dictionary are in baseline section 11. Resolve R1/R2 and obtain detailed-baseline approval before Step 4; do not ask Q1–Q4 again.

### Step 1: Review and obtain approval

- **Action:** Preserve the original review, Q1–Q4 resolutions and iteration 1; record Minh's actual plan approval as YES (19/11/2026), set IN_PROGRESS and append PLAN_APPROVED. Prepare detailed baseline review as iteration 2; leave new R1/R2 OPEN.
- **Verify:** This session changes only baseline/plan/work-log; prior log entries, Word source, SQL and tests remain intact. Approval history reflects the explicit user message; the SQL phase stays gated on the detailed review.

### Step 2: Finalize declarative model and responsibility matrix

- **Action:** Document the following 15-table working model and FK creation order in the baseline, with ERD, every column/type/null/default, keys/checks/indexes, FK actions and DB/application matrix. The stable member identity is the composite PK `(conversation_id,user_id)`, avoiding an unnecessary surrogate; the `membership_periods.period_id` identity distinguishes join intervals. The 15-table count is a consequence of this proposal, not a legacy constraint. E2EE state/envelope fields depend on R1/R2.

| Candidate table | Purpose and principal declarative guarantees |
|---|---|
| `users` | Identity, retained required username/email/name/hash, optional profile, system role, registration source, created time, ACTIVE/LOCKED status and independent `deleted_at`; global unique `lower(username)` and `lower(email)`, username format CHECK; proposed reset reminder flag |
| `login_history` | FK to retained user; required successful-login instant and nonblank full-name/username snapshots; contains UserApp successes only by writer contract; optional IP supports existing admin screen without becoming the activity source |
| `admin_audit_log` | Admin authentication and administrative action events with actor, action/target, time, outcome and identity snapshots; confirmed Q2=A records control correlation/outcome and supports manual retry without an outbox. No password, private key or plaintext message body |
| `friend_requests` | Directed users, status and request/resolution times; no self-request; one unordered PENDING pair through a partial unique index; resolved rows retained |
| `friendships` | Ordered user pair PK plus friendship creation time for the existing detail screen; `user_low_id < user_high_id` |
| `user_blocks` | Directed pair PK and no-self CHECK; block removal does not restore old friendship |
| `conversations` | Identity and PRIVATE/GROUP discriminator, creation/closure metadata, group name/creator where appropriate; S1's `user_low_id/user_high_id` required and ordered only for PRIVATE, NULL for GROUP; PRIVATE pair uniqueness; local shape CHECKs |
| `conversation_members` | One stable member identity per conversation/user, enforced by UNIQUE; personal `last_read_message_id`, `cleared_at` and `cleared_through_message_id`; same-conversation cursor/watermark FKs; retained across departures/rejoins |
| `membership_periods` | Identity for each participation interval, linked to stable member and its conversation/user; joined/left times and period group role; one open period per member via partial unique index; PRIVATE role MEMBER; group role independent of system role |
| `messages` | Retained ID, sender/user/period, time and discriminator; exclusive PRIVATE text or GROUP ciphertext with epoch/device/version; same-conversation/owner/period FKs plus exact sender grant-period FK; R2 envelope format remains OPEN |
| `message_hidden` | Per-user hide identity linked to a message and stable member/owner in the same conversation; unique message/user; persists across rejoining without deleting shared messages |
| `spam_reports` | Reporter/target FKs, optional reason, status, report time and handler/resolution metadata; no self-report; partial unique directed pair WHERE status=PENDING; local status/time consistency |
| `e2ee_devices` | User/device identity, public key and authorization/revocation times; composite owner key; partial unique user WHERE revoked_at IS NULL |
| `group_key_epochs` | GROUP-scoped epoch, start/end times; partial unique conversation WHERE ends_at IS NULL; proposed R1=B adds PENDING/ACTIVE/CLOSED and activated_at, still OPEN |
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

- **Action:** Replace the three SQL files only after Minh selects R1/R2 and approves the detailed baseline in a later session. Remove old triggers/helpers, split-table objects and app-open events from fresh DDL. Use declarative objects, then seed coherent fixtures for roles, snapshots, retained deletion, social retries, two PRIVATE participants, three-person E2EE groups, membership transitions, device changes and all report states. Reuse no real credentials or keys; crypto fixture bytes are opaque test values.
- **Verify:** `schema.sql`, `seed.sql` and revised `verify.sql` execute in order with `ON_ERROR_STOP=1` on an empty disposable DB. Inspect catalogs for the approved inventory, constraints/indexes, zero non-internal triggers and zero custom schema functions/procedures. Tests must not call removed functions or assert old semantics.

### Step 5: Verify reports and visibility

- **Action:** Add SQL assertions for Admin filters/sorts and activity aggregation; count sent PRIVATE counterpart IDs and GROUP conversation IDs distinctly, independently of personal hide/clear state. Use login successes for app-open totals and distinct users for monthly activity; keep AdminApp audit excluded. Keep self-registration separate from admin-created accounts in registration reports. Propose an active-list population of users with a UserApp success in the selected period under O3; send counts are separate columns. Show zero-count months with a 12-month series.
- **Verify:** Use fixtures with two paths to the same second-level user, a triangle, an isolated user, several logins in one month, logins in adjacent months, an AdminApp-only login, deleted historical users and messages hidden by one member. Assert exact expected results and half-open Vietnam-local day/month boundaries. Search/jump/page queries exclude hidden/cleared/ineligible history; do not execute plaintext matching on GROUP ciphertext. Query identity and sort tie-breakers remain stable.

### Step 6: Document actual delivery and report limitations

- **Action:** Update baseline ERD, inventory, query examples, responsibility matrix and commands to match real files. Preserve historical work-log entries; append results with live Vietnam timestamps. Create `database-schema.md` from the feature template only after implementation, describing actual changes and evidence. Record any changed approach as a numbered iteration; never reuse older approvals as this feature's approval.
- **Verify:** Compare every table/FK in the ERD to catalog output, report each criterion below truthfully, and leave server/JDBC/client/crypto checks NOT RUN until separately exercised. Do not declare the full system implemented from database tests alone.

### Alternatives considered

- Keeping separate private/group message tables contradicts the confirmed shared model; S1 is accepted and is not reopened as a choice.
- Keeping triggers or recreating their logic in custom functions violates Minh's constraints. Application transactions make the resulting responsibility explicit.
- Reusing `app_open_events` as a second activity source risks double counting and violates the chosen UserApp login definition.
- A server-held master group key or normal-group toggle conflicts with mandatory E2EE. Store only public keys, wrapped group keys and ciphertext; no server decryption capability is proposed.

## 6. FILES TO CREATE / MODIFY

This table is the change boundary. This session authorizes only baseline, plan and work-log. SQL, tests and the implementation feature document are later-phase deliverables. No file-list expansion is needed; iteration 2 changes phase/order and details only.

| Action | File path | Timing and purpose |
|---|---|---|
| MODIFY | `docs/ai/database-schema/plan.md` | THIS SESSION: record actual approval, iteration 2, detailed-design gate and results; preserve iteration 1 |
| MODIFY | `docs/ai/work-log.md` | THIS SESSION AND LATER: append action/session entries; add/update only the matching progress row |
| MODIFY | `script/schema.sql` | AFTER DETAILED DESIGN APPROVAL: fresh declarative shared schema; not this session |
| MODIFY | `script/seed.sql` | AFTER DETAILED DESIGN APPROVAL: fixtures matching the model; not this session |
| MODIFY | `script/tests/verify.sql` | AFTER DETAILED DESIGN APPROVAL: declarative tests, transaction demonstrations and query assertions; anonymous DO assertions only for tests, no custom assertion function; not this session |
| MODIFY | `docs/database/design-baseline.md` | THIS SESSION: replace obsolete design descriptions with IN_REVIEW detailed ERD/dictionary/constraints/FK actions/creation order/responsibility matrix and OPEN R1/R2; later append real implementation evidence |
| CREATE | `docs/ai/database-schema/database-schema.md` | AFTER IMPLEMENTATION: factual feature documentation using the feature template; not created this session |

Read-only sources, including the Word document, templates, UI plans/docs, requirements specification and project brief, remain unchanged.

## 7. DEPENDENCIES

### Libraries / frameworks

- Target PostgreSQL **17.11**, as recorded in the existing baseline. This session did not contact a DB or verify its installed version. Later use `SHOW server_version_num`; if different, report it before claiming compatibility.
- `psql` and a fresh disposable test DB supplied by the owner; Docker is optional if an existing local PostgreSQL image is available. No installation/download or database/container creation was performed this session.
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

P1–P4 below retain the earlier planning-session results. The approval-NO/two-file scope in P3 describes that earlier session, not the current approved design phase. Current detailed-design checks D1–D4 follow separately.

| ID | Criterion | Verification | Result |
|---|---|---|---|
| P1 | Correct repository and pre-existing changes identified | `git rev-parse --show-toplevel`, branch/origin and initial `git status --short`; source list review | PASS |
| P2 | Requested sources, including Word content, are readable and reviewed | Read all listed Markdown/SQL files and extracted Word body/table text; document priority/conflicts above | PASS |
| P3 | Complete plan; approval remains NO; only two authorized documentation paths change | Final `git status`, `git diff --check`, plan section/placeholder check and work-log preservation comparison | PASS |
| P4 | Session boundaries, action types, timestamps and progress row follow work-log rules | Compare historical entries to HEAD; validate new lines against section 2 types and actual Vietnam clock; verify end entry and tracker | PASS |

| ID | Current detailed-design criterion | How to verify | Result |
|---|---|---|---|
| D1 | Actual approval recorded and unresolved choices remain unresolved | IN_PROGRESS / YES (19/11/2026), Q1–Q4 RESOLVED, R1/R2 OPEN; approval log corresponds to the real user message | PASS |
| D2 | Detailed baseline is internally consistent and explicitly IN_REVIEW | Static review: 15 dictionaries/109 columns, 33 type-matched FKs and ERD edges, six UNIQUE targets, 36 index definitions, local null rules/actions/creation order; Mermaid visual rendering NOT RUN | PASS |
| D3 | Changes remain within the three authorized documents | Git diff/status and unchanged SQL/tests/Word hashes; no application changes or implementation feature document | PASS |
| D4 | Prior logs and iteration history survive; progress is truthful | Pre-session log/tracker preserved except session append and added phase note; iteration 1 intact, truthful tracker and session boundaries | PASS |

### Implementation acceptance checks after approval

All are **NOT RUN**: this session is authorized for detailed design only. Run the following after detailed-baseline approval and implementation on a newly created, explicitly disposable `java_chat_database_schema_test` DB, configured through the owner's normal psql connection settings:

```powershell
psql -X -d java_chat_database_schema_test -v ON_ERROR_STOP=1 -c "SHOW server_version_num;"
psql -X -d java_chat_database_schema_test -v ON_ERROR_STOP=1 -f script/schema.sql
psql -X -d java_chat_database_schema_test -v ON_ERROR_STOP=1 -f script/seed.sql
psql -X -d java_chat_database_schema_test -v ON_ERROR_STOP=1 -f script/tests/verify.sql
```

Do not run these against an existing database. Two-session tests will be documented as literal Session A/Session B SQL in the updated baseline; they are not present or claimed executed yet.

| ID | Criterion | How to verify after implementation | Result |
|---|---|---|---|
| V1 | Fresh schema/seed/tests succeed with the approved inventory and no prohibited DB code | Run commands above; catalog assertions inspect tables/PK/FK/indexes, non-internal triggers and custom functions/procedures | NOT RUN |
| V2 | Identity validation and retained deletion match C2/C3 | Reject too-short/long/non-ASCII/dot usernames and mixed-case duplicates; reject reused identifiers after deletion; retain profile/hash and historical FK references; demonstrate application lifecycle contract | NOT RUN |
| V3 | Login snapshots and statistics distinguish applications | Preserve old snapshots after profile edits/deletion; assert one UserApp success=one open; repeat monthly login does not add another monthly user; AdminApp audit does not add activity | NOT RUN |
| V4 | PRIVATE identity, payload and cross-scope constraints hold | Reject inverted/duplicate endpoint pairs, malformed PRIVATE/GROUP payload shapes, cross-conversation reads/hides/epochs and cross-user grants; transaction demonstrator creates exactly two PRIVATE members | NOT RUN |
| V5 | Social transactions preserve invitation/block rules | Anonymous SQL assertions cover reverse acceptance, re-invite after rejection, cleanup and two-way private block; two psql sessions demonstrate block/send and reciprocal invite races with rollback | NOT RUN |
| V6 | Stable personal state and membership periods preserve history and exact clear boundary | Assert a unique member row across multiple join/leave periods, one open period per member, preserved read/clear/hides on rejoin, period/owner FK rejection, hide-one/hide-many, empty clear, clear/send and timestamp ties, post-clear visibility and monotonic cursor | NOT RUN |
| V7 | Group transactions meet size, role, transfer and exceptional closure rules | Reject/rollback two-person creation and non-admin rename/removal; any member adds eligible person; transfer with eligible successor; otherwise Q1=B closes before leave/soft deletion, retains messages/grants/authorized history and rejects new sends/additions/grants; test close/send and competing last-admin changes | NOT RUN |
| V8 | E2EE storage and transaction eligibility honor O4/Q8 | Reject second current device/open epoch and incorrect grant owner/group; demonstrate new epoch on join/removal/device switch, no back-grants and stale send rejection under the application SQL contract; preserve old metadata | NOT RUN |
| V9 | Spam direction, uniqueness and processing match D37/D38 | Outgoing-only/group-only history does not qualify; hidden incoming private history qualifies; duplicate directed PENDING rejected; opposite-direction report independent; lock resolves all target reports, including prior DISMISSED; ignore records DISMISSED | NOT RUN |
| V10 | Reports/search are accurate and independently scoped | Exact assertions for level-two distinct counts excluding triangles/direct friends/self, distinct chat targets/groups, self-registration, 12 months, Vietnam day/month boundaries and PRIVATE visibility-filtered search/jump/pagination | NOT RUN |
| V11 | ERD, index rationale and feature documentation match verified files | Compare DDL/catalog and ERD column/FK inventory; review selected query EXPLAIN results without requiring a small seed to choose an index; create factual feature doc and append evidence | NOT RUN |

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

## 11. FINAL RESULT

| Field | Value |
|---|---|
| Completion date | Not completed; plan approved, detailed baseline IN_REVIEW and R1/R2 OPEN |
| Commit message to use after implementation | `feat(database-schema): align PostgreSQL schema with confirmed chat requirements` |
| Current result | Plan approved YES (19/11/2026), IN_PROGRESS; detailed design prepared for review; SQL unchanged and implementation checks NOT RUN |
| Feature description | Deferred until implementation; `database-schema.md` has not been created |

Review checkpoint: the plan approval and Q1=B/Q2=A/Q3=B/Q4=A are confirmed. Minh must now select detailed-design R1/R2 and approve the baseline before SQL is written. Plan stays IN_PROGRESS / YES; this narrower review gate does not revoke the actual plan approval.
