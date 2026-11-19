# FEATURE — database-schema

| Field | Value |
|---|---|
| Feature name | `database-schema` |
| Created | 19/11/2026 |
| Last updated | 19/11/2026 |
| Owner(s) | Minh |
| Status | IN_PROGRESS — schema/fixtures/queries executed in isolated test DB; remaining concurrency/integration NOT RUN |
| Related plan | [plan.md](./plan.md) |
| Detailed design | [design-baseline.md](../../database/design-baseline.md) |

## 1. DESCRIPTION

[schema.sql](../../../script/schema.sql) declares the approved shared PRIVATE/GROUP PostgreSQL model using declarative tables, constraints and indexes. Matching seed.sql, queries.sql and verify.sql now execute in a new isolated PostgreSQL17.11 test database: A=48 constraint/catalog checks, B=40 actual query assertions and C=11 rollback-only SQL transaction demonstrations PASS. D server/client/E2EE integration and committed concurrency races remain NOT RUN. This updates the existing feature document; prior approvals and plan iterations remain preserved.

The implementation follows actual choices Q1=B, Q2=A, Q3=B, Q4=A, R1=B and R2=A, plus O1–O4, Q8-A and S1. The pre-implementation question audit found no unanswered DDL-affecting named choice; historical OPEN records remain as history rather than being deleted or interpreted as new questions.

## 2. PURPOSE / USE CASE

- **Actor:** Minh maintaining the database source; future ChatServer and JDBC AdminApp writers.
- **Trigger:** Explicit approval of the detailed design, followed by the request to implement matching fixtures/queries/tests and execute them only on a clearly identified new test DB.
- **Goal:** Provide coherent fresh-database SQL sources, reproducible isolated evidence and explicit DB/application boundaries for accounts, social relations, messaging, E2EE metadata, reporting and administration.

## 3. RELATED CLASSES / FILES

| Action | File path | Actual role in this session |
|---|---|---|
| MODIFIED | `script/schema.sql` | Factual header comments only this iteration; approved DDL unchanged and executed once on the new empty test DB |
| MODIFIED | `script/seed.sql` | Replaced old fixtures with explicit approved-model rows, fake labelled password/crypto data and aligned identity sequences |
| CREATED | `script/queries.sql` | Nine typed session PREPARE statements; common message visibility for history/search/page/around with expected examples |
| MODIFIED | `script/tests/verify.sql` | A/B/C SQL assertions with isolated intentional failures/savepoints/full rollback and D NOT RUN reporting |
| CREATED | `script/tests/negative-cases.md` | Target, run instructions, exact case expectations, categories and untested boundaries |
| MODIFIED | `docs/database/design-baseline.md` | Preserved dictionary/design, synchronized actual fixture/query/catalog evidence and remaining application limits |
| MODIFIED | `docs/ai/database-schema/plan.md` | Preserved approvals/iterations1–4; iteration5 scope/target and truthful per-criterion results |
| MODIFIED | `docs/ai/work-log.md` | Append-only actions/session results and permitted matching progress-tracker updates |
| MODIFIED | `docs/ai/database-schema/database-schema.md` | Existing seven-section factual feature description updated from executed SQL |

No Java/FXML/CSS, templates or Word content changed. No application implementation or integration result is supplied by this SQL work.

## 4. DATA AND PROTOCOL

### Database source changes

Source inventory, now corroborated by A00 against the real test catalog: **15 tables, 109 columns, 15 PKs, 6 table UNIQUE constraints, 33 FKs, 46 CHECKs and 36 explicit indexes**, of which 8 are unique. Total catalog indexes are **57**, including 21 PK/UNIQUE backing indexes. Ten surrogate PK columns use GENERATED ALWAYS AS IDENTITY; the other five PKs are composite.

| Table group | Actual declared tables |
|---|---|
| Account/activity/admin | users, login_history, admin_audit_log |
| Social | friend_requests, friendships, user_blocks |
| Conversation/personal history | conversations, conversation_members, membership_periods, messages, message_hidden |
| E2EE metadata | e2ee_devices, group_key_epochs, group_key_grants |
| Moderation | spam_reports |

The source no longer declares login_events/app_open_events or separate private_conversations/private_messages/private_message_hides/chat_groups/group_memberships/group_messages. The script ran only on a newly created empty test database; no existing database was migrated or had objects removed.

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

### Identified environment and initial execution

| Property | Actual value on 19/11/2026 |
|---|---|
| Existing server/container | chat-postgres a0786fdd6fe1; postgres:17 |
| Published host/port | 127.0.0.1:5432 |
| New test database / owner | jcs_schema_test_20261119_120407_2ed14e / chat_user |
| Server/psql | 17.11; server_version_num170011 |
| Execution transport | docker exec psql through /var/run/postgresql:5432 inside the same server; host TCP NOT RUN |
| Initial isolation | New TEMPLATE template0 database, zero public tables verified before schema |
| Run order/result | schema → seed → nine PREPAREs → verify, all successful |
| Preservation | No business chat_system query, DB/schema deletion, tool install, extension or application change |

Host psql/createdb were absent; the existing Docker container supplied psql. Docker access initially failed inside the sandbox and succeeded after tool approval. Maintenance postgres was used only for metadata and CREATE DATABASE. No password is embedded in sources/logs.

### Repeat rollback-safe tests

Run the following only on the exact seeded test target. It copies source files and reruns verification, not schema/seed:

```powershell
docker cp "D:/java-chat-system/script/." "chat-postgres:/tmp/jcs_schema_test_20261119_120407_2ed14e/"
docker exec chat-postgres psql -h /var/run/postgresql -p 5432 -X -U chat_user -d jcs_schema_test_20261119_120407_2ed14e -v ON_ERROR_STOP=1 -v test_db=jcs_schema_test_20261119_120407_2ed14e -f /tmp/jcs_schema_test_20261119_120407_2ed14e/tests/verify.sql
```

The initial run used the same connection with schema.sql, seed.sql and queries.sql in that order before verify.sql. For a full fresh run, create a new uniquely named empty test database after identifying the server/role; do not delete/reset the old database or rerun schema/seed on it. seed/queries/verify require test_db to match current_database and the dedicated test-name pattern. schema.sql is run-once fresh DDL, not a migration. See [negative-cases.md](../../../script/tests/negative-cases.md) for safety guards, session usage and exact cases.

### Actual results and scope

| Classification | Actual result | What remains unproven |
|---|---|---|
| A — DB/catalog | A00–A47, 48 PASS: inventory/prohibited-object checks plus 47 exact expected SQLSTATE/constraint or NOT NULL-column failures | Only tested cases, not every possible invalid input or application rule |
| B — query results | B01–B40, 40 PASS using actual prepared statements | Authenticated caller identity and production application adoption |
| C — SQL writer contract | C01–C11, 11 PASS, each rolled back | Real JDBC/ChatServer code; two-session committed races NOT RUN |
| D — real integration | D01 NOT RUN | Login/socket/session/control ACK/error UI/device proof/codec/decryption/local keys |

Every intentional A failure is isolated in an anonymous-block subtransaction. C uses per-case savepoints; the outer test transaction rolls back. The final complete 15-table/identity-sequence fingerprint equals the pre-test fingerprint, proving these tests left the fixture unchanged. No helper function/trigger is created and no expected trigger behavior is retained.

B covers Vietnam-local month/day edges under multiple session zones, preserved snapshots, AdminApp exclusion, direct versus only-level-two friends, self-registration, directed spam, D18 search, retained closed-group rights, rejoin state, and one common visibility contract for history/search/page/around. Q01 tests personal read/clear/hide, endpoint/device ownership, revoked/new device denial, missing/hidden/cleared/wrong-conversation anchors and exact ordered results. Group SQL plaintext search returns no rows. Password/key/cipher values remain fake DB fixtures.

EXPLAIN (ANALYZE, BUFFERS) executed for q_chat_messages group history, q_friend_counts and q_activity_monthly. Index paths were observed in history/monthly plans; sequential friendship scans on eight edges are reasonable. No realistic-volume performance guarantee is inferred. Prior static dictionary/FK/index review remains source evidence; actual PostgreSQL execution/catalog results are new evidence.

Plan V1–V11 now has explicit PASS/partial results and the unexecuted cases. Missing long/non-ASCII username edge cases, inverted PRIVATE-pair case, empty-clear/tie/monotonic writer cases, full group add/remove/activation writers and committed concurrency races remain NOT RUN. Mermaid visual rendering, real JDBC/TCP/control, E2EE crypto and deferred client group search are also NOT RUN. Full Verified is not complete.

## 6. TECHNICAL NOTES

- Exactly two PRIVATE canonical endpoints and no duplicate pair are declared. Exactly those two child member rows, no third member and immutable endpoints require application validation/atomic creation. No cross-row count guarantee is claimed for ordinary FKs.
- F21 binds sender conversation/user/period. F22 binds the GROUP epoch; F23 binds the sender grant's exact period/device; F18/F19 bind group/period and device owner. A historic interval reference does not prove a currently authorized sender.
- F24/F25 prevent cross-conversation cursor/cutoff IDs; F26/F27 bind hidden message and owner to the same conversation. Access rights, cursor monotonicity and authenticated ownership remain application checks.
- Q3=B retains one member row and hides across departures/rejoins. Each rejoin gets a new period; Q4=A keeps both clear time and watermark on the stable row. Writers lock the conversation before message-ID allocation and clear cutoff capture to preserve concurrent ordering.
- Group role is independent of system role. Initial three people/creator ADMIN, add-member block checks, rename/grant/remove authority and last-admin transfer/exceptional closure are application transactions, not DB triggers.
- R1=B stores readiness shape and one unended epoch, but the application must reject sends while PENDING, after closure or with stale device/period/epoch. It closes old epochs and validates a complete consistent wrapped-key batch before activation.
- Q8-A/O4 require session termination and generation-based key routing. The DB limits current devices and binds owners; time eligibility/no historical key issuance is application-controlled. Same still-authorized installation re-login preserves its generation/local keys. No mechanism can erase keys already copied to an old client.
- R2=A stores positive codec versions and nonempty opaque bytes, not an implemented cryptographic algorithm. Client/server integration must establish the codec, proof of private-key possession, authenticated headers and consistent key material. No plaintext group search is performed in SQL.
- App-open source is successful UserApp login_history; AdminApp uses admin_audit_log. q_activity_monthly counts distinct users per month and returns twelve months. q_friend_counts deduplicates destinations reached through one direct friend, minus self and every direct friend; no aggregate table/function is introduced.
- Writers must use READ COMMITTED, sorted affected user locks then sorted conversation locks, fresh eligibility checks and atomic updates for social/group/device/report transitions. JDBC/ChatServer must share that protocol; DB declarations do not force arbitrary SQL clients to follow it.

### Changes from the original plan

Iterations 1–3 preserve explicit design answers and prior approval history; iteration 4 records schema-source implementation. Iteration 5 activates the user's requested fixture/query/test/runtime work, adds queries.sql/negative-cases.md to the file boundary before editing, and separates A/B/C/D evidence. No important DDL change, application edit or newly inferred design answer occurred.

## 7. KNOWN ISSUES / LIMITATIONS

- Fresh test-schema/seed execution and the stated A/B/C SQL checks PASS. This does not complete broader V1–V11 acceptance or establish actual application/E2EE behavior. The feature remains IN_PROGRESS.
- verify.sql uses one connection. Concurrent committed block/send, clear/send, admin-transfer/close/send and device-cutover races are NOT RUN; shared sorted lock/recheck contracts still require a two-session harness and application integration.
- No migration/repeatable upgrade or compatibility layer for old table names exists.
- Account/role authorization, one active socket session, login event authenticity, immutable history, legal transitions, full interval non-overlap, block logic and group cardinality are application obligations. Direct SQL may violate them while satisfying every declared constraint.
- FKs restrict referenced deletes/identity updates but do not prohibit deleting every unreferenced row or editing all non-key history/profile fields. Soft-delete-only and immutable records require disciplined writers.
- Audit events do not provide automatic control delivery or crash recovery. A successful JDBC commit cannot stand in for TCP acknowledgement.
- Real E2EE, new-device history restrictions, local key retention, cipher validity, client group search, email reset and LLM integration were not implemented by this schema work.
- B-tree indexes are not proof of fast arbitrary substring search. Three representative EXPLAIN ANALYZE runs succeeded on tiny fixtures; production-volume performance/benchmarks remain NOT RUN. Name ordering/prefix usefulness depends on actual collation/query/planner behavior.
- No commit/push/merge/reset is performed; branch remains fix/db. README's automatic main merge step is overridden by Minh's explicit no-auto-merge instruction; only local ancestry was inspected.

When the whole feature is completed and verified, make its separate commit with message `feat(database-schema): align PostgreSQL schema with confirmed chat requirements`; this session creates no commit.
