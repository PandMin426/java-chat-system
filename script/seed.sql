-- DB FIXTURES ONLY: passwords are NOT BCrypt; public keys, wrapped keys and
-- ciphertext are fake bytes. No real login, device proof or E2EE is demonstrated.
-- Run once after schema.sql in a NEW dedicated jcs_schema_test_* database.
-- Required psql variable: -v test_db=the_exact_database_name
\set ON_ERROR_STOP on
BEGIN;
SELECT set_config('jcs.test_db', :'test_db', false);
DO $guard$
BEGIN
    IF current_database() <> current_setting('jcs.test_db')
       OR current_database() !~ '^jcs_schema_test_[0-9]{8}_[0-9]{6}_[0-9a-f]{6}$' THEN
        RAISE EXCEPTION 'Refusing fixtures outside the explicitly named test database';
    END IF;
    IF EXISTS (SELECT 1 FROM users) THEN
        RAISE EXCEPTION 'Fixtures require an empty schema; do not append or overwrite';
    END IF;
END;
$guard$;

-- Explicit IDs make examples stable. Built-in sequence alignment is at the end.
INSERT INTO users (user_id, username, email, password_hash, full_name,
                   system_role, account_status, registration_source, created_at, deleted_at)
OVERRIDING SYSTEM VALUE VALUES
(1,'Minh','Minh@example.test','DB_FIXTURE_NOT_BCRYPT','Minh Updated','USER','ACTIVE','SELF_REGISTERED','2026-10-31 23:59:59+07',NULL),
(2,'Trang','trang@example.test','DB_FIXTURE_NOT_BCRYPT','Trang Tran','USER','ACTIVE','SELF_REGISTERED','2026-11-01 00:00:00+07',NULL),
(3,'Binh','binh@example.test','DB_FIXTURE_NOT_BCRYPT','Binh Le','USER','ACTIVE','SELF_REGISTERED','2026-11-01 10:00:00+07',NULL),
(4,'Dung','dung@example.test','DB_FIXTURE_NOT_BCRYPT','Dung Vo','USER','ACTIVE','SELF_REGISTERED','2026-11-02 09:00:00+07',NULL),
(5,'Lan','lan@example.test','DB_FIXTURE_NOT_BCRYPT','Lan Pham','USER','ACTIVE','SELF_REGISTERED','2026-10-15 09:00:00+07',NULL),
(6,'Nam','nam@example.test','DB_FIXTURE_NOT_BCRYPT','Nam Ho','USER','ACTIVE','SELF_REGISTERED','2026-11-30 23:59:59.999999+07',NULL),
(7,'Archive','archive@example.test','DB_FIXTURE_NOT_BCRYPT','Archive User','USER','ACTIVE','SELF_REGISTERED','2026-10-01 09:00:00+07','2026-11-08 08:00:00+07'),
(8,'Locked_User','locked@example.test','DB_FIXTURE_NOT_BCRYPT','Locked User','USER','LOCKED','INTERNAL','2026-11-03 00:00:00+07',NULL),
(9,'demo_admin','admin@example.test','DB_FIXTURE_NOT_BCRYPT','Demo Admin','ADMIN','ACTIVE','INTERNAL','2026-10-01 09:00:00+07',NULL),
(10,'Solo','solo@example.test','DB_FIXTURE_NOT_BCRYPT','Solo User','USER','ACTIVE','SELF_REGISTERED','2026-12-01 00:00:00+07',NULL);

-- Synthetic successful UserApp events; actual authentication is NOT tested.
-- Oct/Nov/Dec monthly distinct users: 2/4/3; November has six login rows.
INSERT INTO login_history (login_id,user_id,logged_in_at,username_snapshot,full_name_snapshot,remote_ip)
OVERRIDING SYSTEM VALUE VALUES
(1,1,'2026-10-31 23:59:59.999999+07','Minh','Minh Original','127.0.0.1'),
(2,1,'2026-11-01 00:00:00+07','Minh','Minh Original','127.0.0.1'),
(3,1,'2026-11-30 23:59:59.999999+07','Minh','Minh Updated','127.0.0.1'),
(4,1,'2026-12-01 00:00:00+07','Minh','Minh Updated','127.0.0.1'),
(5,2,'2026-11-01 00:00:00+07','Trang','Trang Tran','127.0.0.2'),
(6,2,'2026-11-15 12:00:00+07','Trang','Trang Tran','127.0.0.2'),
(7,7,'2026-11-05 12:00:00+07','Archive','Archive User','127.0.0.7'),
(8,4,'2026-12-01 12:00:00+07','Dung','Dung Vo','127.0.0.4'),
(9,3,'2026-11-02 10:00:00+07','Binh','Binh Le','127.0.0.3'),
(10,5,'2026-10-15 12:00:00+07','Lan','Lan Pham','127.0.0.5'),
(11,6,'2026-12-02 12:00:00+07','Nam','Nam Ho','127.0.0.6');

-- Minh direct={2,3,5}; level-two={4,6}. 4 is reached through two paths;
-- the 1-2-5 triangle excludes direct friends/self; 7 is three hops from 1.
INSERT INTO friendships(user_low_id,user_high_id,created_at) VALUES
(1,2,'2026-11-04 10:00:00+07'),(1,3,'2026-11-04 10:00:00+07'),
(1,5,'2026-11-04 10:00:00+07'),(2,5,'2026-11-04 10:00:00+07'),
(2,4,'2026-11-04 10:00:00+07'),(3,4,'2026-11-04 10:00:00+07'),
(5,6,'2026-12-02 10:01:00+07'),(4,7,'2026-11-04 10:00:00+07');
INSERT INTO friend_requests(request_id,sender_id,recipient_id,status,requested_at,resolved_at)
OVERRIDING SYSTEM VALUE VALUES
(1,1,2,'ACCEPTED','2026-11-03 10:00:00+07','2026-11-04 10:00:00+07'),
(2,4,6,'REJECTED','2026-12-02 09:00:00+07','2026-12-02 09:01:00+07'),
(3,4,6,'PENDING','2026-12-02 09:02:00+07',NULL),
(4,2,3,'CANCELLED','2026-11-05 10:02:00+07','2026-11-06 08:00:00+07'),
(5,6,5,'ACCEPTED','2026-12-02 10:00:00+07','2026-12-02 10:01:00+07');
-- 2/3 are not friends and their pending request has been cancelled explicitly.
-- They remain members of GROUP 201; shared group visibility is not blocked.
INSERT INTO user_blocks(blocker_id,blocked_id,created_at) VALUES(2,3,'2026-11-06 08:00:00+07');

INSERT INTO conversations(conversation_id,conversation_type,created_by_user_id,
                          private_user_low_id,private_user_high_id,group_name,created_at,closed_at)
OVERRIDING SYSTEM VALUE VALUES
(101,'PRIVATE',1,1,2,NULL,'2026-11-03 08:00:00+07',NULL),
(102,'PRIVATE',2,2,3,NULL,'2026-11-03 08:00:00+07',NULL),
(103,'PRIVATE',1,1,5,NULL,'2026-11-03 08:00:00+07',NULL),
(104,'PRIVATE',1,1,7,NULL,'2026-11-03 08:00:00+07',NULL),
(105,'PRIVATE',1,1,10,NULL,'2026-12-02 08:00:00+07',NULL),
(201,'GROUP',1,NULL,NULL,'Team E2EE fixture','2026-11-03 08:00:00+07',NULL),
(202,'GROUP',7,NULL,NULL,'Closed group fixture','2026-11-04 08:00:00+07','2026-11-08 08:00:00+07'),
(203,'GROUP',1,NULL,NULL,'Pending key fixture','2026-11-11 08:00:00+07',NULL);
INSERT INTO conversation_members(conversation_id,user_id,member_created_at)
SELECT c.conversation_id,v.user_id,c.created_at
FROM (VALUES(101,1),(101,2),(102,2),(102,3),(103,1),(103,5),(104,1),(104,7),
            (105,1),(105,10),(201,1),(201,2),(201,3),(202,7),(202,4),(202,5),
            (203,1),(203,4),(203,5)) AS v(conversation_id,user_id)
JOIN conversations c USING(conversation_id);
INSERT INTO membership_periods(period_id,conversation_id,user_id,conversation_type,group_role,joined_at,left_at)
OVERRIDING SYSTEM VALUE VALUES
(11,101,1,'PRIVATE','MEMBER','2026-11-03 08:00:00+07',NULL),
(12,101,2,'PRIVATE','MEMBER','2026-11-03 08:00:00+07',NULL),
(21,102,2,'PRIVATE','MEMBER','2026-11-03 08:00:00+07',NULL),
(22,102,3,'PRIVATE','MEMBER','2026-11-03 08:00:00+07',NULL),
(31,103,1,'PRIVATE','MEMBER','2026-11-03 08:00:00+07',NULL),
(32,103,5,'PRIVATE','MEMBER','2026-11-03 08:00:00+07',NULL),
(41,104,1,'PRIVATE','MEMBER','2026-11-03 08:00:00+07',NULL),
(42,104,7,'PRIVATE','MEMBER','2026-11-03 08:00:00+07','2026-11-08 08:00:00+07'),
(51,105,1,'PRIVATE','MEMBER','2026-12-02 08:00:00+07',NULL),
(52,105,10,'PRIVATE','MEMBER','2026-12-02 08:00:00+07',NULL),
(101,201,1,'GROUP','ADMIN','2026-11-03 08:00:00+07',NULL),
(102,201,2,'GROUP','MEMBER','2026-11-03 08:00:00+07','2026-11-10 08:00:00+07'),
(103,201,3,'GROUP','MEMBER','2026-11-03 08:00:00+07',NULL),
(104,201,2,'GROUP','MEMBER','2026-11-15 08:00:00+07',NULL),
(201,202,7,'GROUP','ADMIN','2026-11-04 08:00:00+07','2026-11-08 08:00:00+07'),
(202,202,4,'GROUP','MEMBER','2026-11-04 08:00:00+07','2026-11-07 08:00:00+07'),
(203,202,5,'GROUP','MEMBER','2026-11-04 08:00:00+07','2026-11-07 08:00:00+07'),
(301,203,1,'GROUP','ADMIN','2026-11-11 08:00:00+07',NULL),
(302,203,4,'GROUP','MEMBER','2026-11-11 08:00:00+07',NULL),
(303,203,5,'GROUP','MEMBER','2026-11-11 08:00:00+07',NULL);

-- Nonempty fake bytes satisfy storage shape only, not a real codec or crypto.
INSERT INTO e2ee_devices(device_id,user_id,device_uid,public_key,authorized_at,revoked_at)
OVERRIDING SYSTEM VALUE VALUES
(11,1,'00000000-0000-0000-0000-000000000011',decode('aa11','hex'),'2026-11-03 08:00:00+07','2026-11-10 08:00:00+07'),
(12,1,'00000000-0000-0000-0000-000000000012',decode('aa12','hex'),'2026-11-10 08:00:00+07',NULL),
(21,2,'00000000-0000-0000-0000-000000000021',decode('aa21','hex'),'2026-11-03 08:00:00+07',NULL),
(31,3,'00000000-0000-0000-0000-000000000031',decode('aa31','hex'),'2026-11-03 08:00:00+07',NULL),
(41,4,'00000000-0000-0000-0000-000000000041',decode('aa41','hex'),'2026-11-04 08:00:00+07',NULL),
(51,5,'00000000-0000-0000-0000-000000000051',decode('aa51','hex'),'2026-11-04 08:00:00+07',NULL),
(71,7,'00000000-0000-0000-0000-000000000071',decode('aa71','hex'),'2026-11-04 08:00:00+07','2026-11-08 08:00:00+07');
INSERT INTO group_key_epochs(key_epoch_id,conversation_id,epoch_status,starts_at,activated_at,ends_at)
OVERRIDING SYSTEM VALUE VALUES
(1001,201,'CLOSED','2026-11-03 08:00:00+07','2026-11-03 08:01:00+07','2026-11-10 08:00:00+07'),
(1002,201,'CLOSED','2026-11-10 08:00:00+07','2026-11-10 08:01:00+07','2026-11-15 08:00:00+07'),
(1003,201,'ACTIVE','2026-11-15 08:00:00+07','2026-11-15 08:01:00+07',NULL),
(2001,202,'CLOSED','2026-11-04 08:00:00+07','2026-11-04 08:01:00+07','2026-11-08 08:00:00+07'),
(3001,203,'PENDING','2026-11-11 08:00:00+07',NULL,NULL);
INSERT INTO group_key_grants(key_epoch_id,device_id,conversation_id,user_id,period_id,wrapped_key,granted_at)
SELECT v.epoch,v.device,v.conv,v.uid,v.period,decode('bb01','hex'),v.granted::timestamptz
FROM (VALUES
(1001,11,201,1,101,'2026-11-03 08:00:30+07'),(1001,21,201,2,102,'2026-11-03 08:00:30+07'),
(1001,31,201,3,103,'2026-11-03 08:00:30+07'),
(1002,12,201,1,101,'2026-11-10 08:00:30+07'),(1002,31,201,3,103,'2026-11-10 08:00:30+07'),
(1003,12,201,1,101,'2026-11-15 08:00:30+07'),(1003,21,201,2,104,'2026-11-15 08:00:30+07'),
(1003,31,201,3,103,'2026-11-15 08:00:30+07'),
(2001,71,202,7,201,'2026-11-04 08:00:30+07'),(2001,41,202,4,202,'2026-11-04 08:00:30+07'),
(2001,51,202,5,203,'2026-11-04 08:00:30+07')) AS v(epoch,device,conv,uid,period,granted);

INSERT INTO messages(message_id,conversation_id,conversation_type,sender_user_id,sender_period_id,text_content,sent_at)
OVERRIDING SYSTEM VALUE VALUES
(1,101,'PRIVATE',2,12,'Alpha old','2026-11-05 09:00:00+07'),
(2,101,'PRIVATE',1,11,'Minh reply old','2026-11-05 09:01:00+07'),
(3,101,'PRIVATE',2,12,'Alpha hidden','2026-11-05 09:02:00+07'),
(4,101,'PRIVATE',2,12,'Hòa ALPHA visible','2026-11-05 09:03:00+07'),
(5,101,'PRIVATE',1,11,'Minh newer','2026-11-05 09:04:00+07'),
(6,101,'PRIVATE',2,12,'Alpha recent','2026-11-05 09:05:00+07'),
(7,102,'PRIVATE',3,22,'Binh incoming to Trang','2026-11-05 10:00:00+07'),
(8,102,'PRIVATE',2,21,'Trang reply','2026-11-05 10:01:00+07'),
(9,103,'PRIVATE',1,31,'Only outgoing','2026-11-05 11:00:00+07'),
(10,103,'PRIVATE',1,31,'literal 100% underscore_','2026-11-05 11:01:00+07'),
(11,104,'PRIVATE',7,42,'Retained from deleted user','2026-11-05 12:00:00+07'),
(12,104,'PRIVATE',1,41,'Reply to Archive','2026-11-05 12:01:00+07');
-- Sixty received-only messages test the default/clamped 50-row keyset page.
INSERT INTO messages(message_id,conversation_id,conversation_type,sender_user_id,sender_period_id,text_content,sent_at)
OVERRIDING SYSTEM VALUE
SELECT n,105,'PRIVATE',10,52,'page fixture '||n,
       '2026-12-02 10:00:00+07'::timestamptz+(n-20)*interval '1 second'
FROM generate_series(20,79) AS n;
INSERT INTO messages(message_id,conversation_id,conversation_type,sender_user_id,sender_period_id,
                     ciphertext,payload_version,key_epoch_id,sender_device_id,sent_at)
OVERRIDING SYSTEM VALUE VALUES
(1001,201,'GROUP',1,101,decode('cc01','hex'),1,1001,11,'2026-11-05 13:00:00+07'),
(1002,201,'GROUP',2,102,decode('cc02','hex'),1,1001,21,'2026-11-05 13:01:00+07'),
(1003,201,'GROUP',1,101,decode('cc03','hex'),1,1002,12,'2026-11-12 13:00:00+07'),
(1004,201,'GROUP',2,104,decode('cc04','hex'),1,1003,21,'2026-11-16 13:00:00+07'),
(1005,201,'GROUP',3,103,decode('cc05','hex'),1,1003,31,'2026-11-16 13:01:00+07'),
(2001,202,'GROUP',7,201,decode('cc11','hex'),1,2001,71,'2026-11-04 09:00:00+07'),
(2002,202,'GROUP',4,202,decode('cc12','hex'),1,2001,41,'2026-11-04 10:00:00+07');
UPDATE conversation_members SET last_read_message_id=4,cleared_at='2026-11-05 09:01:30+07',cleared_through_message_id=2 WHERE conversation_id=101 AND user_id=1;
UPDATE conversation_members SET last_read_message_id=2 WHERE conversation_id=101 AND user_id=2;
UPDATE conversation_members SET last_read_message_id=1001 WHERE conversation_id=201 AND user_id=2;
UPDATE conversation_members SET last_read_message_id=1003,cleared_at='2026-11-10 08:00:00+07',cleared_through_message_id=1002 WHERE conversation_id=201 AND user_id=3;
INSERT INTO message_hidden(message_id,user_id,conversation_id,hidden_at) VALUES
(3,1,101,'2026-11-05 09:06:00+07'),(4,2,101,'2026-11-05 09:06:00+07'),
(1002,2,201,'2026-11-05 14:00:00+07');

INSERT INTO spam_reports(report_id,reporter_id,reported_user_id,reason,status,reported_at,resolved_at,resolved_by_user_id)
OVERRIDING SYSTEM VALUE VALUES
(1,1,2,NULL,'PENDING','2026-11-06 09:00:00+07',NULL,NULL),
(2,2,1,'Unwanted replies','PENDING','2026-11-06 09:01:00+07',NULL,NULL),
(3,1,7,'Retained archived target','RESOLVED','2026-11-06 10:00:00+07','2026-11-07 10:00:00+07',9),
(4,2,3,'Reviewed and ignored','DISMISSED','2026-11-05 10:05:00+07','2026-11-05 11:00:00+07',9),
(5,2,3,NULL,'PENDING','2026-11-07 09:00:00+07',NULL,NULL);
-- Synthetic audit events, not actual admin authentication/network actions.
INSERT INTO admin_audit_log(audit_id,actor_user_id,actor_username_snapshot,actor_full_name_snapshot,
                            operation_id,event_type,outcome,target_user_id,target_report_id,event_at,detail)
OVERRIDING SYSTEM VALUE VALUES
(1,9,'demo_admin','Demo Admin','00000000-0000-0000-0000-000000000001','LOGIN_SUCCESS','SUCCESS',NULL,NULL,'2026-11-02 10:00:00+07','DB fixture only'),
(2,9,'demo_admin','Demo Admin','00000000-0000-0000-0000-000000000002','USER_SOFT_DELETED','SUCCESS',7,NULL,'2026-11-08 08:00:00+07','Retained profile and identifiers; fixture'),
(3,9,'demo_admin','Demo Admin','00000000-0000-0000-0000-000000000003','SPAM_RESOLVED','SUCCESS',7,3,'2026-11-07 10:00:00+07','Fixture report processing'),
(4,9,'demo_admin','Demo Admin','00000000-0000-0000-0000-000000000004','SPAM_DISMISSED','SUCCESS',3,4,'2026-11-05 11:00:00+07','Fixture report processing'),
(5,9,'demo_admin','Demo Admin','00000000-0000-0000-0000-000000000005','USER_LOCKED','SUCCESS',8,NULL,'2026-11-03 10:00:00+07','Fixture lock'),
(6,9,'demo_admin','Demo Admin','00000000-0000-0000-0000-000000000005','CONTROL_REQUESTED','PENDING',8,NULL,'2026-11-03 10:00:01+07','Fixture, not actual delivery'),
(7,9,'demo_admin','Demo Admin','00000000-0000-0000-0000-000000000005','CONTROL_FAILED','FAILED',8,NULL,'2026-11-03 10:00:02+07','Fixture, not actual failure'),
(8,9,'demo_admin','Demo Admin','00000000-0000-0000-0000-000000000005','CONTROL_REQUESTED','PENDING',8,NULL,'2026-11-03 10:00:03+07','Fixture manual retry'),
(9,9,'demo_admin','Demo Admin','00000000-0000-0000-0000-000000000005','CONTROL_ACKNOWLEDGED','SUCCESS',8,NULL,'2026-11-03 10:00:04+07','Fixture ACK, not actual server evidence');

DO $fixture_check$
BEGIN
    IF EXISTS (SELECT 1 FROM conversations c WHERE conversation_type='GROUP'
        AND (SELECT count(*) FROM membership_periods p WHERE p.conversation_id=c.conversation_id AND p.joined_at=c.created_at)<3) THEN
        RAISE EXCEPTION 'Every fixture group must begin with at least three distinct members';
    END IF;
    IF EXISTS (SELECT 1 FROM spam_reports r WHERE NOT EXISTS (
        SELECT 1 FROM messages m JOIN conversations c USING(conversation_id)
        WHERE c.conversation_type='PRIVATE' AND m.sender_user_id=r.reported_user_id
        AND c.private_user_low_id=LEAST(r.reporter_id,r.reported_user_id)
        AND c.private_user_high_id=GREATEST(r.reporter_id,r.reported_user_id)
        AND m.sent_at<=r.reported_at)) THEN
        RAISE EXCEPTION 'Fixture report lacks earlier incoming PRIVATE evidence';
    END IF;
END;
$fixture_check$;
-- Built-in functions only: explicit fixture IDs must not leave identity defaults
-- pointing at an existing row. Runtime negative cases use overriding IDs so
-- their rollback does not consume nontransactional sequence values.
SELECT setval(pg_get_serial_sequence('users','user_id'),(SELECT max(user_id) FROM users),true);
SELECT setval(pg_get_serial_sequence('login_history','login_id'),(SELECT max(login_id) FROM login_history),true);
SELECT setval(pg_get_serial_sequence('friend_requests','request_id'),(SELECT max(request_id) FROM friend_requests),true);
SELECT setval(pg_get_serial_sequence('conversations','conversation_id'),(SELECT max(conversation_id) FROM conversations),true);
SELECT setval(pg_get_serial_sequence('membership_periods','period_id'),(SELECT max(period_id) FROM membership_periods),true);
SELECT setval(pg_get_serial_sequence('e2ee_devices','device_id'),(SELECT max(device_id) FROM e2ee_devices),true);
SELECT setval(pg_get_serial_sequence('group_key_epochs','key_epoch_id'),(SELECT max(key_epoch_id) FROM group_key_epochs),true);
SELECT setval(pg_get_serial_sequence('messages','message_id'),(SELECT max(message_id) FROM messages),true);
SELECT setval(pg_get_serial_sequence('spam_reports','report_id'),(SELECT max(report_id) FROM spam_reports),true);
SELECT setval(pg_get_serial_sequence('admin_audit_log','audit_id'),(SELECT max(audit_id) FROM admin_audit_log),true);
COMMIT;
