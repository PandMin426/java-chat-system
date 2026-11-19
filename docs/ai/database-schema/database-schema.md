# FEATURE — database-schema

| Field | Value |
|---|---|
| Feature name | `database-schema` |
| Created | 19/11/2026 |
| Last updated | 19/11/2026 |
| Owner(s) | Minh |
| Status | IN_PROGRESS — schema source written; database acceptance NOT RUN |
| Related plan | [plan.md](./plan.md) |
| Detailed design | [design-baseline.md](../../database/design-baseline.md) |

## 1. DESCRIPTION

[schema.sql](../../../script/schema.sql) now declares the approved shared PRIVATE/GROUP PostgreSQL model using declarative tables, constraints and indexes. Its source replaces the earlier split-table/trigger implementation and includes retained profiles, login snapshots, stable personal state, participation periods, E2EE metadata and spam/administration records. The script has not been run on PostgreSQL; fixtures, database acceptance and application integration remain unfinished.

The implementation follows actual choices Q1=B, Q2=A, Q3=B, Q4=A, R1=B and R2=A, plus O1–O4, Q8-A and S1. The pre-implementation question audit found no unanswered DDL-affecting named choice; historical OPEN records remain as history rather than being deleted or interpreted as new questions.

## 2. PURPOSE / USE CASE

- **Actor:** Minh maintaining the database source; future ChatServer and JDBC AdminApp writers.
- **Trigger:** Explicit user approval of the detailed design and instruction to implement schema.sql without database execution.
- **Goal:** Provide a coherent fresh-database DDL source and explicit DB/application boundaries for accounts, social relations, messaging, groups, E2EE metadata, reporting and administration.

## 3. RELATED CLASSES / FILES

| Action | File path | Actual role in this session |
|---|---|---|
| MODIFIED | `script/schema.sql` | Replaced old source with approved 15-table declarative DDL and indexes |
| MODIFIED | `docs/database/design-baseline.md` | Synchronized approved design to actual source objects, static counts and unresolved implementation limits |
| MODIFIED | `docs/ai/database-schema/plan.md` | Recorded detailed approval/answer audit, iteration 4, current scope and static-vs-runtime verification |
| MODIFIED | `docs/ai/work-log.md` | Append-only approval/actions/session results and permitted progress-tracker changes |
| CREATED | `docs/ai/database-schema/database-schema.md` | This factual in-progress feature description, using the feature-template structure |

No Java/FXML/CSS, seed.sql, verify.sql, templates or Word content was changed. No application class implements this new schema contract yet in this feature.

## 4. DATA AND PROTOCOL

### Database source changes

Static source inventory: **15 tables, 109 columns, 15 PKs, 6 table UNIQUE constraints, 33 FKs, 46 CHECKs and 36 explicit indexes**, of which 8 are unique. Ten surrogate PK columns use GENERATED ALWAYS AS IDENTITY; the other five PKs are composite. These counts describe source declarations, not a live catalog.

| Table group | Actual declared tables |
|---|---|
| Account/activity/admin | users, login_history, admin_audit_log |
| Social | friend_requests, friendships, user_blocks |
| Conversation/personal history | conversations, conversation_members, membership_periods, messages, message_hidden |
| E2EE metadata | e2ee_devices, group_key_epochs, group_key_grants |
| Moderation | spam_reports |

The source no longer declares login_events/app_open_events or separate private_conversations/private_messages/private_message_hides/chat_groups/group_memberships/group_messages. No database was migrated or had those objects removed: this script is for a new empty database only.

Declared constraints and indexes provide:

- Required retained account fields, username regex `^[A-Za-z0-9_]{3,30}$`, global case-insensitive username/email uniqueness including deleted accounts, and ACTIVE/LOCKED plus independent deleted_at. BCrypt correctness and login eligibility are application checks.
- Required login snapshots and a separate administration audit; one logical UserApp success per row is a server writer contract, not a DB authentication detector.
- Ordered unique friendship pairs, directed block pairs, one unordered PENDING invitation pair and one directed PENDING spam-report pair.
- PRIVATE ordered endpoint pair and partial unique pair index; mutually exclusive PRIVATE/GROUP row shapes and text/ciphertext payloads.
- Stable member PK `(conversation_id,user_id)`, one open membership period per member, same-conversation read/clear pointer FKs, and a hide owner/message tied to the same conversation.
- GROUP-only epochs, one unended epoch per group, one unrevoked device generation per account, exact period/group/device-owner grant FKs, and a GROUP message FK to its sender's exact epoch/device/period grant.
- Row-local PENDING/ACTIVE/CLOSED epoch/time shape under R1=B and nonempty versioned opaque envelope fields under R2=A. FK presence does not prove current ACTIVE eligibility or valid cryptography.
- All 33 FKs explicitly use MATCH SIMPLE, ON DELETE RESTRICT, ON UPDATE RESTRICT and NOT DEFERRABLE. Nullable E2EE pointers are bypassed only for PRIVATE under its payload shape; nullable read/clear pointers intentionally permit first join/empty clear.

Creation order is users → user-dependent tables → stable members → participation periods/epochs → grants → messages → pointer FK ALTER → hides/reports → audit, then indexes. F24/F25 are added after messages exists, resolving the member/message/period cycle without deferred constraints or a custom helper. Wider U01–U06 unique targets bind owner/scope dimensions and are intentional; no duplicate plain history index is added over U06.

The script contains BEGIN/COMMIT around CREATE TABLE, one ALTER TABLE for the two pointer FKs and CREATE INDEX statements. It contains no business trigger, stored procedure, custom function, extension installation or database/schema deletion command. No CHECK queries another table.

### Socket messages

N/A — no network implementation or application files changed. The approved future topology remains UserApp → plain TCP ChatServer → DB, and AdminApp → JDBC DB plus a server control channel. Q2=A requires truthful acknowledgement/failure audit and idempotent manual retry; schema storage does not implement that channel or confirm any session was terminated. No WebSocket library/API is introduced.

## 5. HOW TO RUN / TEST

### Prerequisites for a future authorized execution

- An explicitly disposable, empty PostgreSQL test database and normal psql connection settings supplied by its operator. Target version is 17.11 from the approved project target; installed version was not checked this session.
- Detailed baseline/plan remain the source for transaction responsibilities.
- Rewrite seed.sql and tests/verify.sql before using them with this schema. Both unchanged files currently target removed objects and old rules and are incompatible.

### How to run

**No PostgreSQL command was executed in this session.** The following is a future operator instruction, status NOT RUN, for an already provisioned empty disposable database; it is not execution evidence:

```powershell
psql -X -d java_chat_database_schema_test -v ON_ERROR_STOP=1 -f script/schema.sql
```

Do not run this against an existing application database or rerun it as an upgrade. Do not follow it with the old seed/verification files. This feature adds no database-creation/deletion command and performs no migration.

### Static source review actually performed

An inline Node.js source checker read schema.sql and baseline without a DB connection. It compared every column/type/null/default, PK/UNIQUE target, FK arity/type/scope and declaration order; reviewed statement classes, object-name lengths and duplicate index definitions; and matched all 33 FK signatures to the baseline catalog. Source counts were 15/109/15/6/33/46/36 as reported above. `git diff --check` and scoped source-hash checks are recorded in work-log. This is lexical/source-consistency review, **not** the PostgreSQL parser, catalog inspection or runtime constraint testing.

### How to test — implementation acceptance remains unfinished

| Plan check | Future verification | Result |
|---|---|---|
| V1 | Fresh DB accepts schema plus rewritten fixtures/assertions; inspect real inventory and prohibited objects | NOT RUN |
| V2 | Reject malformed/case-duplicate/reused deleted identifiers; retain profile/history; exercise lifecycle writer contract | NOT RUN |
| V3 | Preserve login snapshots and exclude AdminApp from UserApp activity/monthly distinct counts | NOT RUN |
| V4 | Reject wrong PRIVATE/payload shape and cross-conversation/period/device/grant references; demonstrate exact-two-member creation | NOT RUN |
| V5 | Exercise reciprocal invitations, rejection/re-invite and atomic block cleanup/send races | NOT RUN |
| V6 | Exercise stable rejoin state, read monotonicity, hides and clear/send boundary/timestamp ties | NOT RUN |
| V7 | Exercise group size/roles, explicit transfer or exceptional closure, retained history and close/send race | NOT RUN |
| V8 | Exercise single current device/epoch, owner scope, no back-grants and application cutover/activation under concurrency | NOT RUN |
| V9 | Exercise directed spam eligibility/PENDING uniqueness, DISMISSED and D38 all-report resolution | NOT RUN |
| V10 | Verify level-two-only distinct friends, activity/registration/window counts and visibility-filtered PRIVATE search/navigation | NOT RUN |
| V11 | Compare real catalog/ERD, inspect representative query plans and finalize evidence/documentation | NOT RUN |

Mermaid visual rendering, JDBC/TCP sessions/control errors, E2EE codec/decryption/device proof and client group search are also NOT RUN. No old test PASS is reused here.

## 6. TECHNICAL NOTES

- Exactly two PRIVATE canonical endpoints and no duplicate pair are declared. Exactly those two child member rows, no third member and immutable endpoints require application validation/atomic creation. No cross-row count guarantee is claimed for ordinary FKs.
- F21 binds sender conversation/user/period. F22 binds the GROUP epoch; F23 binds the sender grant's exact period/device; F18/F19 bind group/period and device owner. A historic interval reference does not prove a currently authorized sender.
- F24/F25 prevent cross-conversation cursor/cutoff IDs; F26/F27 bind hidden message and owner to the same conversation. Access rights, cursor monotonicity and authenticated ownership remain application checks.
- Q3=B retains one member row and hides across departures/rejoins. Each rejoin gets a new period; Q4=A keeps both clear time and watermark on the stable row. Writers lock the conversation before message-ID allocation and clear cutoff capture to preserve concurrent ordering.
- Group role is independent of system role. Initial three people/creator ADMIN, add-member block checks, rename/grant/remove authority and last-admin transfer/exceptional closure are application transactions, not DB triggers.
- R1=B stores readiness shape and one unended epoch, but the application must reject sends while PENDING, after closure or with stale device/period/epoch. It closes old epochs and validates a complete consistent wrapped-key batch before activation.
- Q8-A/O4 require session termination and generation-based key routing. The DB limits current devices and binds owners; time eligibility/no historical key issuance is application-controlled. Same still-authorized installation re-login preserves its generation/local keys. No mechanism can erase keys already copied to an old client.
- R2=A stores positive codec versions and nonempty opaque bytes, not an implemented cryptographic algorithm. Client/server integration must establish the codec, proof of private-key possession, authenticated headers and consistent key material. No plaintext group search is performed in SQL.
- App-open source is successful UserApp login_history; AdminApp uses admin_audit_log. Distinct level-two friends are destinations reached through one direct friend, deduplicated, minus self and every direct friend. No aggregate table/function is introduced; query implementations remain later work.
- Writers must use READ COMMITTED, sorted affected user locks then sorted conversation locks, fresh eligibility checks and atomic updates for social/group/device/report transitions. JDBC/ChatServer must share that protocol; DB declarations do not force arbitrary SQL clients to follow it.

### Changes from the original plan

Iterations 1–3 preserve explicit design answers and prior approval history. Iteration 4 records actual detailed-design approval and narrows this session to schema-source implementation plus factual IN_PROGRESS documentation. Planned seed/assertion/concurrency/integration work is deferred; no scope expansion, application change or DB execution occurred.

## 7. KNOWN ISSUES / LIMITATIONS

- PostgreSQL syntax acceptance, execution, real catalog and every runtime constraint/query/concurrency test are NOT RUN. Source review cannot establish that the database has run successfully.
- Existing seed.sql and verify.sql are stale/incompatible; rewriting them and running the approved checks remains required work. The feature is not DONE.
- No migration/repeatable upgrade or compatibility layer for old table names exists.
- Account/role authorization, one active socket session, login event authenticity, immutable history, legal transitions, full interval non-overlap, block logic and group cardinality are application obligations. Direct SQL may violate them while satisfying every declared constraint.
- FKs restrict referenced deletes/identity updates but do not prohibit deleting every unreferenced row or editing all non-key history/profile fields. Soft-delete-only and immutable records require disciplined writers.
- Audit events do not provide automatic control delivery or crash recovery. A successful JDBC commit cannot stand in for TCP acknowledgement.
- Real E2EE, new-device history restrictions, local key retention, cipher validity, client group search, email reset and LLM integration were not implemented by this schema work.
- B-tree indexes are not proof of fast arbitrary substring search; query EXPLAIN/performance remains NOT RUN. Name ordering/prefix usefulness depends on actual collation/query/planner behavior.
- No commit/push/merge/reset is performed; branch remains fix/db. README's automatic main merge step is overridden by Minh's explicit no-auto-merge instruction; only local ancestry was inspected.

When the whole feature is completed and verified, make its separate commit with message `feat(database-schema): align PostgreSQL schema with confirmed chat requirements`; this session creates no commit.
