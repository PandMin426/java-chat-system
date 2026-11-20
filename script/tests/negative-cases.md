# database-schema verification and negative cases

Status: **IN_PROGRESS**. Actual DB results below were obtained on 19/11/2026 (Asia/Ho_Chi_Minh). This is a database fixture/SQL test suite, not evidence of application authentication or functioning E2EE.

## 1. Target and execution

| Property | Actual isolated target |
|---|---|
| Server/container | Docker Desktop, `chat-postgres`, container `a0786fdd6fe1`, postgres:17 |
| Published host/port | `127.0.0.1:5432` |
| Database | `jcs_schema_test_20261119_120407_2ed14e` |
| Role/owner | `chat_user` |
| Server and psql | PostgreSQL 17.11; server_version_num=170011 |
| Actual connection transport | `docker exec` → psql → Unix socket `/var/run/postgresql`, port 5432 inside this same server |
| Isolation evidence | Created with TEMPLATE template0; public table count zero before schema. Maintenance postgres used only for metadata/CREATE DATABASE; business chat_system not queried |
| Schema/seed | Executed once in that order, both committed successfully; nine PREPAREs loaded successfully |
| Verification | A=48 PASS; B=40 PASS; C=11 SQL simulations PASS; D=1 NOT RUN; final full row/identity-sequence fingerprint unchanged |
| Representative EXPLAIN ANALYZE | q_chat_messages group history, q_friend_counts and q_activity_monthly executed successfully; tiny fixture is not a performance benchmark |

No tool installation, extension, database/schema deletion or application change occurred. Host TCP connectivity itself was not exercised. No password is printed or embedded here.

The files use psql syntax. seed.sql, queries.sql and verify.sql require `-v test_db=EXACT_DATABASE_NAME` and reject a database name different from that value or outside `^jcs_schema_test_[0-9]{8}_[0-9]{6}_[0-9a-f]{6}$`. This is an accident-prevention guard, not an authorization system. schema.sql is fresh-database DDL: check the target and emptiness before running it. Do not rerun schema or seed on this populated database. A later complete rerun requires a new uniquely named empty test database; retain previous databases, never drop/reset them.

Repeat only the rollback-safe verification on the identified seeded database:

```powershell
docker cp "D:/java-chat-system/script/." "chat-postgres:/tmp/jcs_schema_test_20261119_120407_2ed14e/"
docker exec chat-postgres psql -h /var/run/postgresql -p 5432 -X -U chat_user -d jcs_schema_test_20261119_120407_2ed14e -v ON_ERROR_STOP=1 -v test_db=jcs_schema_test_20261119_120407_2ed14e -f /tmp/jcs_schema_test_20261119_120407_2ed14e/tests/verify.sql
```

The initial run used the same psql connection/guard arguments with `-f .../schema.sql`, then `-f .../seed.sql`, then `-f .../queries.sql`, then `-f .../tests/verify.sql`. `\ir ../queries.sql` inside verify.sql loads the actual prepared statements in the same psql session. PREPARE does not create stored database code. To try examples interactively, load queries.sql and EXECUTE in one connection; parameters use typed PREPARE/`$1` bindings, not string concatenation. Real JDBC consumers must bind parameters, enforce authenticated identities/roles, and adapt the psql harness rather than execute its test guard in production.

## 2. Classification and isolation

| Category | What PASS establishes | Actual result |
|---|---|---|
| A. DB constraints/catalog | PostgreSQL rejects precisely the tested violation; checks actual catalog inventory | 48 PASS (A00 plus A01–A47) |
| B. Query results | Actual queries.sql prepared statements return exact fixture IDs/counts and visibility | 40 PASS |
| C. Application transaction contracts | Explicit SQL writer predicates/atomic changes work in rollback-only demonstrations; deliberately unsafe direct SQL reveals DB boundaries | 11 PASS; application implementation NOT RUN |
| D. Server/client/E2EE integration | Actual TCP/JDBC authentication, kicks, acknowledgements, encrypted key exchange and client behavior | NOT RUN; no application or crypto exercised |

A00 checks 15 tables/109 columns/15 PK/6 table UNIQUE/33 FK/46 CHECK/57 total indexes (36 explicit plus 21 constraint backing), restrictive immediate FK actions, 10 users/79 messages/19 stable members/20 periods, and absence of custom public functions/procedures/non-internal triggers/unapproved extensions. plpgsql is PostgreSQL's default language extension, not a newly installed extension.

Each A01–A47 statement runs in its own anonymous-block EXCEPTION subtransaction, checks exact SQLSTATE and constraint name (or NOT NULL column), and rolls back its failed statement. Unexpected success or a different error fails verification. SQLSTATE 23505=unique, 23503=FK, 23514=CHECK, 23502=NOT NULL. The exact executable SQL is the ID-labelled VALUES matrix in verify.sql; no trigger error text is expected.

All C cases have individual SAVEPOINT → mutations/assertions → ROLLBACK TO → RELEASE boundaries. The outer transaction is rolled back after printing results. Explicit OVERRIDING SYSTEM VALUE IDs avoid advancing identity sequences during tests; complete fingerprints compare all 15 tables and sequence values before/after. On an unexpected failure, ON_ERROR_STOP aborts psql and disconnect rolls back the open transaction. No helper function or trigger is created. Do not run deliberate failures in an autocommit sequence or continue after unexpected errors.

## 3. A — intentional constraint failures

All following cases actually PASS on the target above.

| ID | Deliberate violation | SQLSTATE | Exact constraint/index or column |
|---|---|---|---|
| A01 | Case-insensitive live username duplicate | 23505 | `users_username_ci_uidx` |
| A02 | Deleted account username remains reserved | 23505 | `users_username_ci_uidx` |
| A03 | Deleted account email remains reserved, case-insensitively | 23505 | `users_email_ci_uidx` |
| A04 | Username shorter than three characters | 23514 | `users_username_format_check` |
| A05 | Username contains a dot | 23514 | `users_username_format_check` |
| A06 | Required username is NULL | 23502 | `username` (NOT NULL column) |
| A07 | Login references missing user | 23503 | `login_history_user_fk` |
| A08 | Friendship pair inverted | 23514 | `friendships_ordered_pair_check` |
| A09 | Duplicate friendship | 23505 | `friendships_pkey` |
| A10 | Self block | 23514 | `user_blocks_distinct_users_check` |
| A11 | Reverse duplicate PENDING invitation | 23505 | `friend_requests_pending_pair_uidx` |
| A12 | Duplicate PRIVATE endpoint pair | 23505 | `conversations_private_pair_uidx` |
| A13 | Incomplete PRIVATE endpoint pair | 23514 | `conversations_shape_check` |
| A14 | GROUP payload also contains plaintext | 23514 | `messages_payload_shape_check` |
| A15 | Sender period belongs to another user | 23503 | `messages_sender_period_fk` |
| A16 | Sender period belongs to another conversation | 23503 | `messages_sender_period_fk` |
| A17 | Read pointer in another conversation | 23503 | `conversation_members_read_message_fk` |
| A18 | Clear watermark in another conversation | 23503 | `conversation_members_clear_message_fk` |
| A19 | Hidden message in another conversation | 23503 | `message_hidden_message_fk` |
| A20 | Hide owner not a stable member | 23503 | `message_hidden_member_fk` |
| A21 | Second open participation period | 23505 | `membership_periods_open_member_uidx` |
| A22 | PRIVATE member role ADMIN | 23514 | `membership_periods_private_role_check` |
| A23 | Second current device for account | 23505 | `e2ee_devices_current_user_uidx` |
| A24 | Second unended epoch | 23505 | `group_key_epochs_unended_uidx` |
| A25 | ACTIVE epoch without activation instant | 23514 | `group_key_epochs_state_check` |
| A26 | GROUP epoch attached to PRIVATE | 23503 | `group_key_epochs_conversation_type_fk` |
| A27 | Grant period is valid but device belongs to another account | 23503 | `group_key_grants_device_owner_fk` |
| A28 | Grant references another user's period | 23503 | `group_key_grants_period_fk` |
| A29 | Grant period/device valid in different group, epoch mismatches | 23503 | `group_key_grants_epoch_fk` |
| A30 | Sender device/grant belongs to another user | 23503 | `messages_sender_grant_period_fk` |
| A31 | Sender grant references different participation period | 23503 | `messages_sender_grant_period_fk` |
| A32 | Second directed PENDING report | 23505 | `spam_reports_pending_pair_uidx` |
| A33 | PENDING report with resolution metadata | 23514 | `spam_reports_resolution_check` |
| A34 | Invalid spam status IGNORED | 23514 | `spam_reports_status_check` |
| A35 | GROUP payload version NULL | 23514 | `messages_payload_shape_check` |
| A36 | Clear watermark without cleared_at | 23514 | `conversation_members_clear_state_check` |
| A37 | Delete grant referenced by a message | 23503 | `messages_sender_grant_period_fk` |
| A38 | Change referenced device owner | 23503 | `group_key_grants_device_owner_fk` |
| A39 | Email contains surrounding spaces | 23514 | `users_email_trimmed_check` |
| A40 | Blank login name snapshot | 23514 | `login_history_full_name_snapshot_check` |
| A41 | Control audit missing target user | 23514 | `admin_audit_log_control_target_check` |
| A42 | Empty GROUP ciphertext | 23514 | `messages_payload_shape_check` |
| A43 | PENDING invitation with resolution instant | 23514 | `friend_requests_resolution_check` |
| A44 | Epoch activation before start | 23514 | `group_key_epochs_activated_at_check` |
| A45 | Departure before join | 23514 | `membership_periods_left_at_check` |
| A46 | Empty wrapped key | 23514 | `group_key_grants_wrapped_key_check` |
| A47 | DELETED is not an account_status value (deleted_at is separate) | 23514 | `users_account_status_check` |

A27–A29 modify the unreferenced sender grant (epoch1003/device12) so another child's restrictive FK cannot mask the intended owner/period/epoch error. A30–A31 test the exact sender-grant-period relation separately.

## 4. B — query contracts and expected results

All following cases actually PASS. Rows are listed in returned order; “none” means zero rows. A failed/hidden cursor or anchor returns no result instead of exposing another member's message. unread is the visible, incoming-only conversation total before pagination/search.

| ID | Actual parameterized query | Expected IDs | Expected visible unread |
|---|---|---|---|
| B01 | `EXECUTE q_chat_messages(1,12,101,'HISTORY',NULL,NULL,NULL,50)` | 6, 5, 4 | 1 |
| B02 | `EXECUTE q_chat_messages(1,12,101,'HISTORY',NULL,NULL,NULL,2)` | 6, 5 | 1 |
| B03 | `EXECUTE q_chat_messages(1,12,101,'HISTORY',5,NULL,NULL,50)` | 4 | 1 |
| B04 | `EXECUTE q_chat_messages(1,12,101,'SEARCH',NULL,'ALPHA',NULL,50)` | 6, 4 | 1 |
| B05 | `EXECUTE q_chat_messages(1,12,101,'AROUND',NULL,NULL,5,3)` | 4, 5, 6 | 1 |
| B06 | `EXECUTE q_chat_messages(1,12,101,'AROUND',NULL,NULL,3,3)` | none | N/A (no row) |
| B07 | `EXECUTE q_chat_messages(1,12,101,'AROUND',NULL,NULL,2,3)` | none | N/A (no row) |
| B08 | `EXECUTE q_chat_messages(4,41,101,'HISTORY',NULL,NULL,NULL,50)` | none | N/A (no row) |
| B09 | `EXECUTE q_chat_messages(1,12,101,'AROUND',NULL,NULL,7,3)` | none | N/A (no row) |
| B10 | `EXECUTE q_chat_messages(2,21,101,'HISTORY',NULL,NULL,NULL,50)` | 6, 5, 3, 2, 1 | 1 |
| B11 | `EXECUTE q_chat_messages(1,12,201,'HISTORY',NULL,NULL,NULL,50)` | 1005, 1004, 1003 | 2 |
| B12 | `EXECUTE q_chat_messages(1,11,201,'HISTORY',NULL,NULL,NULL,50)` | none | N/A (no row) |
| B13 | `EXECUTE q_chat_messages(2,21,201,'HISTORY',NULL,NULL,NULL,50)` | 1005, 1004, 1001 | 1 |
| B14 | `EXECUTE q_chat_messages(3,31,201,'HISTORY',NULL,NULL,NULL,50)` | 1005, 1004, 1003 | 1 |
| B15 | `EXECUTE q_chat_messages(9,NULL,NULL,'HISTORY',NULL,NULL,NULL,50)` | none | N/A (no row) |
| B16 | `EXECUTE q_chat_messages(2,21,201,'SEARCH',NULL,'fixture',NULL,50)` | none | N/A (no row) |
| B17 | `EXECUTE q_chat_messages(4,41,202,'HISTORY',NULL,NULL,NULL,50)` | 2002, 2001 | 1 |
| B18 | `EXECUTE q_chat_messages(7,71,104,'HISTORY',NULL,NULL,NULL,50)` | none | N/A (no row) |
| B19 | `EXECUTE q_chat_messages(1,12,104,'HISTORY',NULL,NULL,NULL,50)` | 12, 11 | 1 |
| B20 | `EXECUTE q_chat_messages(1,12,NULL,'SEARCH',NULL,'%',NULL,50)` | 10 | not asserted |
| B21 | `EXECUTE q_chat_messages(1,12,105,'HISTORY',NULL,NULL,NULL,999)` | 79…30 (50 rows) | 60 |
| B22 | `EXECUTE q_chat_messages(1,12,105,'HISTORY',30,NULL,NULL,50)` | 29, 28, 27, 26, 25, 24, 23, 22, 21, 20 | 60 |
| B23 | `EXECUTE q_chat_messages(1,12,101,'HISTORY',3,NULL,NULL,50)` | none | N/A (no row) |
| B24 | `EXECUTE q_chat_messages(1,12,101,'HISTORY',7,NULL,NULL,50)` | none | N/A (no row) |
| B25 | `EXECUTE q_chat_messages(1,21,201,'HISTORY',NULL,NULL,NULL,50)` | none | N/A (no row) |
| B26 | `EXECUTE q_chat_messages(1,12,NULL,'AROUND',NULL,NULL,5,3)` | none | N/A (no row) |
| B27 | `EXECUTE q_chat_messages(1,12,101,'SEARCH',NULL,'HÒA',NULL,50)` | 4 | not asserted |
| B28 | `EXECUTE q_chat_messages(1,12,101,'SEARCH',NULL,'Hoa',NULL,50)` | none | N/A (no row) |
| B29 | `EXECUTE q_chat_messages(1,12,101,'HISTORY',NULL,NULL,NULL,0)` | 6 | 1 |
| B30 | `EXECUTE q_chat_messages(1,12,203,'HISTORY',NULL,NULL,NULL,50)` | none | N/A (no row) |

| ID | Query/check | Expected fixture result |
|---|---|---|
| B31 | q_friend_counts(1), (10) | Minh direct=3, only-level-two=2 ({4,6}); isolated10=0/0. Two paths to4 deduplicate; self/direct triangle excluded;7 is third-hop |
| B32 | q_login_history(1,'2026-11-01','2026-11-30') | Login IDs3,2; ID2 retains Minh Original despite current Minh Updated |
| B33 | q_activity_monthly(2026), repeated under UTC and America/New_York session zones | Jan–Sep0, Oct2, Nov4, Dec3 distinct UserApp users; explicit Vietnam boundaries independent of session zone |
| B34 | q_activity(NULL, November dates) | user:opens:private-people:groups = 1:2:3:1, 2:2:2:1, 3:1:1:1, 7:1:1:1 |
| B35 | q_new_users(November dates) | IDs2,3,4,6; Nov30 last microsecond included; Dec1 midnight excluded |
| B36 | q_spam_list(NULL,'PENDING',November), q_spam_list(3,NULL,November) | Reports5,2,1; reports5,4 respectively |
| B37 | q_find_users(3,'Trang',50), (2,'Binh',50), (1,'Archive',50), (2,'MINH',50) | none, user3, none, user1; D18 search direction and deleted exclusion |
| B38 | q_group_periods(201,true,NULL), (201,false,'ADMIN'), (202,false,NULL) | Periods101,102,103,104;101;none |
| B39 | q_activity(1,December), q_activity(4,November), AdminApp-only audit | Minh opens1/private0/group0 despite 60 received messages; Dung absent; admin9 has no UserApp login |
| B40 | Fixture provenance/lifecycle assertions | Deleted profile/IDs retained; fake password bytes labelled; three initial members per GROUP; Trang has one stable member row and two periods in201 |

Use [queries.sql](../queries.sql) for every typed parameter, NULL/default rule, date interpretation and expected example. Q01 returns ciphertext plus the viewer's authorized wrapped envelope from the SAME visibility path; history, keyset page, literal PRIVATE search and around-anchor cannot diverge on hidden/cleared/device/period restrictions. Group plaintext SQL search returns none. Case-insensitive search preserves accents: HÒA matches Hòa; Hoa does not. % and _ are literal characters.

Q02–Q07 are privileged admin/report metadata; Q08 is UserApp search; Q09 requires the appropriate administrative/group role. The SQL caller must not choose another viewer/device identity. Report metadata does not grant access to message bodies.

## 5. C — application SQL demonstrations and DB boundaries

All eleven sequential, rollback-only demonstrations PASS. They are not automated production writer functions and do not prove Java/JDBC callers implement them.

| ID | SQL contract or unsafe counterexample | Expected result |
|---|---|---|
| C01 | Lock users4,6 sorted; accept reverse pending invitation and insert ordered friendship atomically | One accepted request plus friendship inside savepoint; rollback restores PENDING |
| C02 | Lock pair1,5; block and delete friendship explicitly | Block exists and friendship absent inside savepoint; no automatic trigger cleanup |
| C03 | Lock pair4,6; block and explicitly cancel pending invitations both ways | Request3 CANCELLED; historical rejection retained |
| C04 | Sorted user/group locks; transfer group201 ADMIN1→2 before1 leaves; close old epoch/open PENDING epoch | Successor remains ADMIN; member/read/hide identity is stable; rollback restores original state |
| C05 | Sorted users/conversations; revoke device12, authorize13, rotate open group epochs | Old and newly authorized generation cannot query old grant history; full rollback. No real socket kick or crypto proof |
| C06 | Lock users3,9; lock3 and resolve ALL target reports, audit processing | Prior DISMISSED4 and PENDING5 become RESOLVED; locked viewer gets no history; rollback |
| C07 | Deliberately insert third PRIVATE member4/period/message | DB accepts valid scoped FKs; canonical endpoint guard denies viewer4. Exactly two child members requires application writer validation |
| C08 | Deliberately report1→5 with outgoing-only history | DB accepts; explicit incoming-PRIVATE eligibility predicate is false. Application must reject before insert |
| C09 | Deliberately grant/send against PENDING group203 | DB accepts structurally valid rows; ACTIVE predicate false and canonical query returns none. Application must prevent send/grant policy violations |
| C10 | Guard rename by active group ADMIN; check distinct creation cardinality | Non-admin affects0, ADMIN affects1; [1,2,2] fails minimum3, [1,2,3] passes predicate |
| C11 | Remove eligible successors in203; exceptional closure before last-admin leave | Closed conversation/epoch, all stable member data retained, closed202 messages still present; rollback |

**Concurrency status: NOT RUN.** The committed races in plan V5–V8 (reverse invite vs invite, block vs send, clear vs send, competing last-admin removal, close vs send, device cutover vs send) require a two-session writer harness following baseline section9.1's lock protocol and section10's responsibility matrix. The current automated suite has a single connection; it verifies transaction predicates/boundaries, not competing committed operations. No claim of concurrent application correctness is made.

For each future two-session race, use the same identified isolated test environment and dedicated fixture rows: sessionA locks all affected users ascending, then conversations ascending, then dependencies; sessionB attempts the same sorted lock set and must wait. A commits its transition, B acquires the locks, re-reads eligibility and either performs the valid serialized action or rolls back. Assert retained history, no duplicate active device/epoch/member, and no stale send/partial cleanup. Capture both outcomes; use a fresh test DB for each committed fixture-changing full rerun rather than resetting/deleting databases. Last-admin/close/device scenarios must share the same locks as sends. A lock wait alone does not prove rechecking or correct committed outcomes.

## 6. D — integration handoff

| ID | Required real integration | Current outcome / reason |
|---|---|---|
| D01 | TCP UserApp login; one active session; old-session kick; JDBC AdminApp lock with ACK/failure/manual retry; current device proof; membership/device rotation and codec/decryption; same-device retained local keys | NOT RUN: this task edits SQL/docs only; fake hashes/envelopes have no valid BCrypt/cryptographic meaning and no application was exercised |

New-member and new-device history denial has B/C query/contract coverage; actual key secrecy, client-held key behavior, old-client cached ciphertext/key erasure (not guaranteed), complete batch activation, email reset and client group search remain integration work. Group search at the client is explicitly deferred. Performance at realistic data volume, Mermaid visual rendering and migrations are also NOT RUN/out of scope.

