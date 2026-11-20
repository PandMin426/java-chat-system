-- Dedicated test DB only; run after schema.sql then seed.sql.
-- A: real constraints. B: actual queries.sql results. C: rolled-back SQL
-- contract simulations/boundaries, NOT proof of application implementation.
-- D: real server/client/E2EE integration remains NOT RUN.
-- No helper function/trigger is created. Anonymous blocks are assertions only.
-- Every expected A error runs in its own subtransaction and checks exact
-- SQLSTATE + constraint/column. Overriding IDs avoid sequence side effects.
\set ON_ERROR_STOP on
\ir ../queries.sql
SELECT md5(jsonb_build_object(
'users',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.user_id) FROM users t),
'login_history',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.login_id) FROM login_history t),
'friend_requests',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.request_id) FROM friend_requests t),
'friendships',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.user_low_id,t.user_high_id) FROM friendships t),
'user_blocks',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.blocker_id,t.blocked_id) FROM user_blocks t),
'conversations',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.conversation_id) FROM conversations t),
'conversation_members',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.conversation_id,t.user_id) FROM conversation_members t),
'membership_periods',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.period_id) FROM membership_periods t),
'e2ee_devices',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.device_id) FROM e2ee_devices t),
'group_key_epochs',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.key_epoch_id) FROM group_key_epochs t),
'group_key_grants',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.key_epoch_id,t.device_id) FROM group_key_grants t),
'messages',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.message_id) FROM messages t),
'message_hidden',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.message_id,t.user_id) FROM message_hidden t),
'spam_reports',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.report_id) FROM spam_reports t),
'admin_audit_log',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.audit_id) FROM admin_audit_log t),
'sequences',(SELECT jsonb_object_agg(sequencename,last_value) FROM pg_sequences WHERE schemaname='public'))::text) AS before_fingerprint \gset
BEGIN;
CREATE TEMP TABLE verification_results(category text,case_id text,result text,detail text) ON COMMIT DROP;
DO $catalog$
DECLARE expected_tables text[] := ARRAY['admin_audit_log','conversation_members','conversations','e2ee_devices','friend_requests','friendships','group_key_epochs','group_key_grants','login_history','membership_periods','message_hidden','messages','spam_reports','user_blocks','users'];
BEGIN
    IF (SELECT array_agg(tablename::text ORDER BY tablename) FROM pg_tables WHERE schemaname='public') IS DISTINCT FROM expected_tables THEN RAISE EXCEPTION 'A00 table inventory'; END IF;
    IF (SELECT count(*) FROM information_schema.columns WHERE table_schema='public')<>109 THEN RAISE EXCEPTION 'A00 columns'; END IF;
    IF (SELECT count(*) FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public' AND c.contype='p')<>15
       OR (SELECT count(*) FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public' AND c.contype='f')<>33
       OR (SELECT count(*) FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public' AND c.contype='u')<>6
       OR (SELECT count(*) FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public' AND c.contype='c')<>46 THEN RAISE EXCEPTION 'A00 constraints'; END IF;
    IF EXISTS(SELECT 1 FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public' AND c.contype='f' AND (c.confdeltype<>'r' OR c.confupdtype<>'r' OR c.confmatchtype<>'s' OR c.condeferrable)) THEN RAISE EXCEPTION 'A00 FK actions'; END IF;
    IF (SELECT count(*) FROM pg_indexes WHERE schemaname='public')<>57 THEN RAISE EXCEPTION 'A00 indexes including PK/UNIQUE backing indexes'; END IF;
    IF EXISTS(SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public')
       OR EXISTS(SELECT 1 FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND NOT t.tgisinternal)
       OR EXISTS(SELECT 1 FROM pg_extension WHERE extname<>'plpgsql') THEN RAISE EXCEPTION 'A00 prohibited helpers/extensions'; END IF;
    IF (SELECT count(*) FROM users)<>10 OR (SELECT count(*) FROM messages)<>79 OR (SELECT count(*) FROM conversation_members)<>19 OR (SELECT count(*) FROM membership_periods)<>20 THEN RAISE EXCEPTION 'A00 fixture counts'; END IF;
    INSERT INTO verification_results VALUES('A','A00','PASS','Catalog: 15 tables/109 columns/15 PK/6 UNIQUE/33 FK/46 CHECK/57 total indexes; no custom helpers');
END;
$catalog$;

DO $negative$
DECLARE c record; observed_state text; observed_constraint text; observed_column text;
BEGIN
    FOR c IN SELECT * FROM (VALUES
('A01',$sql$INSERT INTO users(user_id,username,email,password_hash,full_name,registration_source) OVERRIDING SYSTEM VALUE VALUES(-90001,'mINH','a01@example.test','DB_FIXTURE_NOT_BCRYPT','Fixture','SELF_REGISTERED')$sql$,'23505','users_username_ci_uidx',NULL),
('A02',$sql$INSERT INTO users(user_id,username,email,password_hash,full_name,registration_source) OVERRIDING SYSTEM VALUE VALUES(-90002,'aRcHiVe','a02@example.test','DB_FIXTURE_NOT_BCRYPT','Fixture','SELF_REGISTERED')$sql$,'23505','users_username_ci_uidx',NULL),
('A03',$sql$INSERT INTO users(user_id,username,email,password_hash,full_name,registration_source) OVERRIDING SYSTEM VALUE VALUES(-90003,'EmailReuse','ARCHIVE@EXAMPLE.TEST','DB_FIXTURE_NOT_BCRYPT','Fixture','SELF_REGISTERED')$sql$,'23505','users_email_ci_uidx',NULL),
('A04',$sql$INSERT INTO users(user_id,username,email,password_hash,full_name,registration_source) OVERRIDING SYSTEM VALUE VALUES(-90004,'ab','a04@example.test','DB_FIXTURE_NOT_BCRYPT','Fixture','SELF_REGISTERED')$sql$,'23514','users_username_format_check',NULL),
('A05',$sql$INSERT INTO users(user_id,username,email,password_hash,full_name,registration_source) OVERRIDING SYSTEM VALUE VALUES(-90005,'bad.name','a05@example.test','DB_FIXTURE_NOT_BCRYPT','Fixture','SELF_REGISTERED')$sql$,'23514','users_username_format_check',NULL),
('A06',$sql$INSERT INTO users(user_id,username,email,password_hash,full_name,registration_source) OVERRIDING SYSTEM VALUE VALUES(-90006,NULL,'a06@example.test','DB_FIXTURE_NOT_BCRYPT','Fixture','SELF_REGISTERED')$sql$,'23502',NULL,'username'),
('A07',$sql$INSERT INTO login_history(login_id,user_id,username_snapshot,full_name_snapshot) OVERRIDING SYSTEM VALUE VALUES(-90007,999999,'Missing','Missing')$sql$,'23503','login_history_user_fk',NULL),
('A08',$sql$INSERT INTO friendships(user_low_id,user_high_id) VALUES(3,1)$sql$,'23514','friendships_ordered_pair_check',NULL),
('A09',$sql$INSERT INTO friendships(user_low_id,user_high_id) VALUES(1,2)$sql$,'23505','friendships_pkey',NULL),
('A10',$sql$INSERT INTO user_blocks(blocker_id,blocked_id) VALUES(4,4)$sql$,'23514','user_blocks_distinct_users_check',NULL),
('A11',$sql$INSERT INTO friend_requests(request_id,sender_id,recipient_id,requested_at) OVERRIDING SYSTEM VALUE VALUES(-90011,6,4,'2026-12-03 10:00:00+07')$sql$,'23505','friend_requests_pending_pair_uidx',NULL),
('A12',$sql$INSERT INTO conversations(conversation_id,conversation_type,created_by_user_id,private_user_low_id,private_user_high_id) OVERRIDING SYSTEM VALUE VALUES(-90012,'PRIVATE',1,1,2)$sql$,'23505','conversations_private_pair_uidx',NULL),
('A13',$sql$INSERT INTO conversations(conversation_id,conversation_type,created_by_user_id,private_user_high_id) OVERRIDING SYSTEM VALUE VALUES(-90013,'PRIVATE',1,2)$sql$,'23514','conversations_shape_check',NULL),
('A14',$sql$INSERT INTO messages(message_id,conversation_id,conversation_type,sender_user_id,sender_period_id,text_content,ciphertext,payload_version,key_epoch_id,sender_device_id,sent_at) OVERRIDING SYSTEM VALUE VALUES(-90014,201,'GROUP',2,104,'plaintext forbidden',decode('cc99','hex'),1,1003,21,'2026-12-03 10:00:00+07')$sql$,'23514','messages_payload_shape_check',NULL),
('A15',$sql$INSERT INTO messages(message_id,conversation_id,conversation_type,sender_user_id,sender_period_id,text_content) OVERRIDING SYSTEM VALUE VALUES(-90015,101,'PRIVATE',3,11,'fixture')$sql$,'23503','messages_sender_period_fk',NULL),
('A16',$sql$INSERT INTO messages(message_id,conversation_id,conversation_type,sender_user_id,sender_period_id,text_content) OVERRIDING SYSTEM VALUE VALUES(-90016,102,'PRIVATE',1,11,'fixture')$sql$,'23503','messages_sender_period_fk',NULL),
('A17',$sql$UPDATE conversation_members SET last_read_message_id=7 WHERE conversation_id=101 AND user_id=1$sql$,'23503','conversation_members_read_message_fk',NULL),
('A18',$sql$UPDATE conversation_members SET cleared_through_message_id=7 WHERE conversation_id=101 AND user_id=1$sql$,'23503','conversation_members_clear_message_fk',NULL),
('A19',$sql$INSERT INTO message_hidden(message_id,user_id,conversation_id) VALUES(7,1,101)$sql$,'23503','message_hidden_message_fk',NULL),
('A20',$sql$INSERT INTO message_hidden(message_id,user_id,conversation_id) VALUES(1,4,101)$sql$,'23503','message_hidden_member_fk',NULL),
('A21',$sql$INSERT INTO membership_periods(period_id,conversation_id,user_id,conversation_type,joined_at) OVERRIDING SYSTEM VALUE VALUES(-90021,201,2,'GROUP','2026-12-03 10:00:00+07')$sql$,'23505','membership_periods_open_member_uidx',NULL),
('A22',$sql$UPDATE membership_periods SET group_role='ADMIN' WHERE period_id=11$sql$,'23514','membership_periods_private_role_check',NULL),
('A23',$sql$INSERT INTO e2ee_devices(device_id,user_id,device_uid,public_key,authorized_at) OVERRIDING SYSTEM VALUE VALUES(-90023,1,'00000000-0000-0000-0000-000000090023',decode('aa99','hex'),'2026-12-03 10:00:00+07')$sql$,'23505','e2ee_devices_current_user_uidx',NULL),
('A24',$sql$INSERT INTO group_key_epochs(key_epoch_id,conversation_id,starts_at) OVERRIDING SYSTEM VALUE VALUES(-90024,201,'2026-12-03 10:00:00+07')$sql$,'23505','group_key_epochs_unended_uidx',NULL),
('A25',$sql$UPDATE group_key_epochs SET epoch_status='ACTIVE' WHERE key_epoch_id=3001$sql$,'23514','group_key_epochs_state_check',NULL),
('A26',$sql$INSERT INTO group_key_epochs(key_epoch_id,conversation_id) OVERRIDING SYSTEM VALUE VALUES(-90026,101)$sql$,'23503','group_key_epochs_conversation_type_fk',NULL),
('A27',$sql$UPDATE group_key_grants SET user_id=2,period_id=104 WHERE key_epoch_id=1003 AND device_id=12$sql$,'23503','group_key_grants_device_owner_fk',NULL),
('A28',$sql$UPDATE group_key_grants SET period_id=104 WHERE key_epoch_id=1003 AND device_id=12$sql$,'23503','group_key_grants_period_fk',NULL),
('A29',$sql$UPDATE group_key_grants SET conversation_id=202,user_id=4,period_id=202,device_id=41 WHERE key_epoch_id=1003 AND device_id=12$sql$,'23503','group_key_grants_epoch_fk',NULL),
('A30',$sql$INSERT INTO messages(message_id,conversation_id,conversation_type,sender_user_id,sender_period_id,text_content,ciphertext,payload_version,key_epoch_id,sender_device_id,sent_at) OVERRIDING SYSTEM VALUE VALUES(-90030,201,'GROUP',2,104,NULL,decode('cc99','hex'),1,1003,12,'2026-12-03 10:00:00+07')$sql$,'23503','messages_sender_grant_period_fk',NULL),
('A31',$sql$INSERT INTO messages(message_id,conversation_id,conversation_type,sender_user_id,sender_period_id,text_content,ciphertext,payload_version,key_epoch_id,sender_device_id,sent_at) OVERRIDING SYSTEM VALUE VALUES(-90031,201,'GROUP',2,102,NULL,decode('cc99','hex'),1,1003,21,'2026-12-03 10:00:00+07')$sql$,'23503','messages_sender_grant_period_fk',NULL),
('A32',$sql$INSERT INTO spam_reports(report_id,reporter_id,reported_user_id) OVERRIDING SYSTEM VALUE VALUES(-90032,1,2)$sql$,'23505','spam_reports_pending_pair_uidx',NULL),
('A33',$sql$UPDATE spam_reports SET resolved_at='2026-12-03 10:00:00+07' WHERE report_id=1$sql$,'23514','spam_reports_resolution_check',NULL),
('A34',$sql$UPDATE spam_reports SET status='IGNORED',resolved_at='2026-12-03 10:00:00+07',resolved_by_user_id=9 WHERE report_id=1$sql$,'23514','spam_reports_status_check',NULL),
('A35',$sql$UPDATE messages SET payload_version=NULL WHERE message_id=1004$sql$,'23514','messages_payload_shape_check',NULL),
('A36',$sql$UPDATE conversation_members SET cleared_at=NULL WHERE conversation_id=101 AND user_id=1$sql$,'23514','conversation_members_clear_state_check',NULL),
('A37',$sql$DELETE FROM group_key_grants WHERE key_epoch_id=1002 AND device_id=12$sql$,'23503','messages_sender_grant_period_fk',NULL),
('A38',$sql$UPDATE e2ee_devices SET user_id=10 WHERE device_id=21$sql$,'23503','group_key_grants_device_owner_fk',NULL),
('A39',$sql$UPDATE users SET email=' space@example.test ' WHERE user_id=1$sql$,'23514','users_email_trimmed_check',NULL),
('A40',$sql$UPDATE login_history SET full_name_snapshot=' ' WHERE login_id=2$sql$,'23514','login_history_full_name_snapshot_check',NULL),
('A41',$sql$UPDATE admin_audit_log SET target_user_id=NULL WHERE audit_id=6$sql$,'23514','admin_audit_log_control_target_check',NULL),
('A42',$sql$UPDATE messages SET ciphertext=''::bytea WHERE message_id=1004$sql$,'23514','messages_payload_shape_check',NULL),
('A43',$sql$UPDATE friend_requests SET resolved_at='2026-12-03 10:00:00+07' WHERE request_id=3$sql$,'23514','friend_requests_resolution_check',NULL),
('A44',$sql$UPDATE group_key_epochs SET activated_at=starts_at-interval '1 second' WHERE key_epoch_id=1003$sql$,'23514','group_key_epochs_activated_at_check',NULL),
('A45',$sql$UPDATE membership_periods SET left_at=joined_at-interval '1 second' WHERE period_id=104$sql$,'23514','membership_periods_left_at_check',NULL),
('A46',$sql$UPDATE group_key_grants SET wrapped_key=''::bytea WHERE key_epoch_id=1003 AND device_id=12$sql$,'23514','group_key_grants_wrapped_key_check',NULL),
('A47',$sql$UPDATE users SET account_status='DELETED' WHERE user_id=1$sql$,'23514','users_account_status_check',NULL)
    ) AS cases(case_id,statement,expected_state,expected_constraint,expected_column) LOOP
        observed_state:=NULL; observed_constraint:=NULL; observed_column:=NULL;
        BEGIN
            EXECUTE c.statement;
        EXCEPTION WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS observed_state=RETURNED_SQLSTATE,observed_constraint=CONSTRAINT_NAME,observed_column=COLUMN_NAME;
        END; -- failed statement is rolled back before the next case
        IF observed_state IS DISTINCT FROM c.expected_state
           OR (c.expected_constraint IS NOT NULL AND observed_constraint IS DISTINCT FROM c.expected_constraint)
           OR (c.expected_column IS NOT NULL AND observed_column IS DISTINCT FROM c.expected_column) THEN
            RAISE EXCEPTION '% expected %/%/%, got %/%/%',c.case_id,c.expected_state,c.expected_constraint,c.expected_column,observed_state,observed_constraint,observed_column;
        END IF;
        INSERT INTO verification_results VALUES('A',c.case_id,'PASS',c.expected_state||' '||coalesce(c.expected_constraint,c.expected_column));
    END LOOP;
END;
$negative$;

DO $visible_queries$
DECLARE c record; r record; ids bigint[]; wrong_unread boolean;
BEGIN
    FOR c IN SELECT * FROM (VALUES
('B01','EXECUTE q_chat_messages(1,12,101,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[6,5,4]::bigint[],1::bigint),
('B02','EXECUTE q_chat_messages(1,12,101,''HISTORY'',NULL,NULL,NULL,2)',ARRAY[6,5]::bigint[],1::bigint),
('B03','EXECUTE q_chat_messages(1,12,101,''HISTORY'',5,NULL,NULL,50)',ARRAY[4]::bigint[],1::bigint),
('B04','EXECUTE q_chat_messages(1,12,101,''SEARCH'',NULL,''ALPHA'',NULL,50)',ARRAY[6,4]::bigint[],1::bigint),
('B05','EXECUTE q_chat_messages(1,12,101,''AROUND'',NULL,NULL,5,3)',ARRAY[4,5,6]::bigint[],1::bigint),
('B06','EXECUTE q_chat_messages(1,12,101,''AROUND'',NULL,NULL,3,3)',ARRAY[]::bigint[],NULL::bigint),
('B07','EXECUTE q_chat_messages(1,12,101,''AROUND'',NULL,NULL,2,3)',ARRAY[]::bigint[],NULL::bigint),
('B08','EXECUTE q_chat_messages(4,41,101,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[]::bigint[],NULL::bigint),
('B09','EXECUTE q_chat_messages(1,12,101,''AROUND'',NULL,NULL,7,3)',ARRAY[]::bigint[],NULL::bigint),
('B10','EXECUTE q_chat_messages(2,21,101,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[6,5,3,2,1]::bigint[],1::bigint),
('B11','EXECUTE q_chat_messages(1,12,201,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[1005,1004,1003]::bigint[],2::bigint),
('B12','EXECUTE q_chat_messages(1,11,201,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[]::bigint[],NULL::bigint),
('B13','EXECUTE q_chat_messages(2,21,201,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[1005,1004,1001]::bigint[],1::bigint),
('B14','EXECUTE q_chat_messages(3,31,201,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[1005,1004,1003]::bigint[],1::bigint),
('B15','EXECUTE q_chat_messages(9,NULL,NULL,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[]::bigint[],NULL::bigint),
('B16','EXECUTE q_chat_messages(2,21,201,''SEARCH'',NULL,''fixture'',NULL,50)',ARRAY[]::bigint[],NULL::bigint),
('B17','EXECUTE q_chat_messages(4,41,202,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[2002,2001]::bigint[],1::bigint),
('B18','EXECUTE q_chat_messages(7,71,104,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[]::bigint[],NULL::bigint),
('B19','EXECUTE q_chat_messages(1,12,104,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[12,11]::bigint[],1::bigint),
('B20','EXECUTE q_chat_messages(1,12,NULL,''SEARCH'',NULL,''%'',NULL,50)',ARRAY[10]::bigint[],NULL::bigint),
('B21','EXECUTE q_chat_messages(1,12,105,''HISTORY'',NULL,NULL,NULL,999)',ARRAY[79,78,77,76,75,74,73,72,71,70,69,68,67,66,65,64,63,62,61,60,59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30]::bigint[],60::bigint),
('B22','EXECUTE q_chat_messages(1,12,105,''HISTORY'',30,NULL,NULL,50)',ARRAY[29,28,27,26,25,24,23,22,21,20]::bigint[],60::bigint),
('B23','EXECUTE q_chat_messages(1,12,101,''HISTORY'',3,NULL,NULL,50)',ARRAY[]::bigint[],NULL::bigint),
('B24','EXECUTE q_chat_messages(1,12,101,''HISTORY'',7,NULL,NULL,50)',ARRAY[]::bigint[],NULL::bigint),
('B25','EXECUTE q_chat_messages(1,21,201,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[]::bigint[],NULL::bigint),
('B26','EXECUTE q_chat_messages(1,12,NULL,''AROUND'',NULL,NULL,5,3)',ARRAY[]::bigint[],NULL::bigint),
('B27','EXECUTE q_chat_messages(1,12,101,''SEARCH'',NULL,''HÒA'',NULL,50)',ARRAY[4]::bigint[],NULL::bigint),
('B28','EXECUTE q_chat_messages(1,12,101,''SEARCH'',NULL,''Hoa'',NULL,50)',ARRAY[]::bigint[],NULL::bigint),
('B29','EXECUTE q_chat_messages(1,12,101,''HISTORY'',NULL,NULL,NULL,0)',ARRAY[6]::bigint[],1::bigint),
('B30','EXECUTE q_chat_messages(1,12,203,''HISTORY'',NULL,NULL,NULL,50)',ARRAY[]::bigint[],NULL::bigint)
    ) AS cases(case_id,statement,expected_ids,expected_unread) LOOP
        ids:=ARRAY[]::bigint[]; wrong_unread:=false;
        FOR r IN EXECUTE c.statement LOOP
            ids:=array_append(ids,r.message_id);
            IF c.expected_unread IS NOT NULL AND r.visible_unread_count<>c.expected_unread THEN wrong_unread:=true; END IF;
        END LOOP;
        IF ids IS DISTINCT FROM c.expected_ids OR wrong_unread THEN RAISE EXCEPTION '% expected IDs %, got %, wrong unread %',c.case_id,c.expected_ids,ids,wrong_unread; END IF;
        INSERT INTO verification_results VALUES('B',c.case_id,'PASS',c.expected_ids::text);
    END LOOP;
END;
$visible_queries$;


DO $report_queries$
DECLARE r record; ids bigint[]; pairs text[]; month_counts bigint[]; saved_tz text; n integer;
BEGIN
    EXECUTE 'EXECUTE q_friend_counts(1)' INTO r;
    IF r.direct_count<>3 OR r.level_two_count<>2 THEN RAISE EXCEPTION 'B31 direct/level-two'; END IF;
    EXECUTE 'EXECUTE q_friend_counts(10)' INTO r;
    IF r.direct_count<>0 OR r.level_two_count<>0 THEN RAISE EXCEPTION 'B31 isolated'; END IF;
    INSERT INTO verification_results VALUES('B','B31','PASS','Minh 3 direct / 2 level-two; Solo 0/0');

    ids:=ARRAY[]::bigint[];
    FOR r IN EXECUTE $$EXECUTE q_login_history(1,'2026-11-01','2026-11-30')$$ LOOP
        ids:=array_append(ids,r.login_id);
        IF r.login_id=2 AND r.full_name_snapshot<>'Minh Original' THEN RAISE EXCEPTION 'B32 snapshot rewritten'; END IF;
    END LOOP;
    IF ids<>ARRAY[3,2]::bigint[] OR (SELECT full_name FROM users WHERE user_id=1)<>'Minh Updated' THEN RAISE EXCEPTION 'B32 boundary/snapshot'; END IF;
    INSERT INTO verification_results VALUES('B','B32','PASS','Vietnam login range IDs 3,2; historical name retained');

    saved_tz:=current_setting('TimeZone');
    FOREACH saved_tz IN ARRAY ARRAY['UTC','America/New_York'] LOOP
        PERFORM set_config('TimeZone',saved_tz,true);
        month_counts:=ARRAY[]::bigint[];
        FOR r IN EXECUTE 'EXECUTE q_activity_monthly(2026)' LOOP month_counts:=array_append(month_counts,r.active_users); END LOOP;
        IF month_counts<>ARRAY[0,0,0,0,0,0,0,0,0,2,4,3]::bigint[] THEN RAISE EXCEPTION 'B33 monthly %, tz %',month_counts,saved_tz; END IF;
    END LOOP;
    PERFORM set_config('TimeZone','UTC',true);
    INSERT INTO verification_results VALUES('B','B33','PASS','12 Vietnam months independent of UTC/New_York session zone');

    pairs:=ARRAY[]::text[];
    FOR r IN EXECUTE $$EXECUTE q_activity(NULL,'2026-11-01','2026-11-30')$$ LOOP
        pairs:=array_append(pairs,format('%s:%s:%s:%s',r.user_id,r.app_opens,r.private_people,r.groups_sent));
    END LOOP;
    IF pairs<>ARRAY['1:2:3:1','2:2:2:1','3:1:1:1','7:1:1:1'] THEN RAISE EXCEPTION 'B34 activity %',pairs; END IF;
    INSERT INTO verification_results VALUES('B','B34','PASS',pairs::text);

    ids:=ARRAY[]::bigint[];
    FOR r IN EXECUTE $$EXECUTE q_new_users('2026-11-01','2026-11-30')$$ LOOP ids:=array_append(ids,r.user_id); END LOOP;
    IF ids<>ARRAY[2,3,4,6]::bigint[] THEN RAISE EXCEPTION 'B35 registration %',ids; END IF;
    INSERT INTO verification_results VALUES('B','B35','PASS',ids::text);

    ids:=ARRAY[]::bigint[];
    FOR r IN EXECUTE $$EXECUTE q_spam_list(NULL,'PENDING','2026-11-01','2026-11-30')$$ LOOP ids:=array_append(ids,r.report_id); END LOOP;
    IF ids<>ARRAY[5,2,1]::bigint[] THEN RAISE EXCEPTION 'B36 pending %',ids; END IF;
    ids:=ARRAY[]::bigint[];
    FOR r IN EXECUTE $$EXECUTE q_spam_list(3,NULL,'2026-11-01','2026-11-30')$$ LOOP ids:=array_append(ids,r.report_id); END LOOP;
    IF ids<>ARRAY[5,4]::bigint[] THEN RAISE EXCEPTION 'B36 target %',ids; END IF;
    INSERT INTO verification_results VALUES('B','B36','PASS','Pending 5,2,1; target 3 has pending/dismissed 5,4');

    n:=0; FOR r IN EXECUTE $$EXECUTE q_find_users(3,'Trang',50)$$ LOOP n:=n+1; END LOOP;
    IF n<>0 THEN RAISE EXCEPTION 'B37 blocked user found blocker'; END IF;
    ids:=ARRAY[]::bigint[]; FOR r IN EXECUTE $$EXECUTE q_find_users(2,'Binh',50)$$ LOOP ids:=array_append(ids,r.user_id); END LOOP;
    IF ids<>ARRAY[3]::bigint[] THEN RAISE EXCEPTION 'B37 asymmetric block %',ids; END IF;
    n:=0; FOR r IN EXECUTE $$EXECUTE q_find_users(1,'Archive',50)$$ LOOP n:=n+1; END LOOP;
    IF n<>0 THEN RAISE EXCEPTION 'B37 deleted profile in live search'; END IF;
    ids:=ARRAY[]::bigint[]; FOR r IN EXECUTE $$EXECUTE q_find_users(2,'MINH',50)$$ LOOP ids:=array_append(ids,r.user_id); END LOOP;
    IF ids<>ARRAY[1]::bigint[] THEN RAISE EXCEPTION 'B37 case search'; END IF;
    INSERT INTO verification_results VALUES('B','B37','PASS','D18 asymmetric, case-insensitive; deleted excluded from live search');

    ids:=ARRAY[]::bigint[]; FOR r IN EXECUTE 'EXECUTE q_group_periods(201,true,NULL)' LOOP ids:=array_append(ids,r.period_id); END LOOP;
    IF ids<>ARRAY[101,102,103,104]::bigint[] THEN RAISE EXCEPTION 'B38 periods %',ids; END IF;
    ids:=ARRAY[]::bigint[]; FOR r IN EXECUTE $$EXECUTE q_group_periods(201,false,'ADMIN')$$ LOOP ids:=array_append(ids,r.period_id); END LOOP;
    IF ids<>ARRAY[101]::bigint[] THEN RAISE EXCEPTION 'B38 group role'; END IF;
    n:=0; FOR r IN EXECUTE 'EXECUTE q_group_periods(202,false,NULL)' LOOP n:=n+1; END LOOP;
    IF n<>0 THEN RAISE EXCEPTION 'B38 closed group active list'; END IF;
    INSERT INTO verification_results VALUES('B','B38','PASS','Stable user 2 has periods 102/104; system role is not group role');

    EXECUTE $$EXECUTE q_activity(1,'2026-12-01','2026-12-31')$$ INTO r;
    IF r.app_opens<>1 OR r.private_people<>0 OR r.groups_sent<>0 THEN RAISE EXCEPTION 'B39 received-only counted as sent'; END IF;
    n:=0; FOR r IN EXECUTE $$EXECUTE q_activity(4,'2026-11-01','2026-11-30')$$ LOOP n:=n+1; END LOOP;
    IF n<>0 OR EXISTS(SELECT 1 FROM login_history WHERE user_id=9) THEN RAISE EXCEPTION 'B39 O3 population/admin'; END IF;
    INSERT INTO verification_results VALUES('B','B39','PASS','Received-only and message-only do not inflate O3 activity');

    IF (SELECT count(*) FROM users WHERE password_hash='DB_FIXTURE_NOT_BCRYPT')<>10
       OR (SELECT username FROM users WHERE user_id=7)<>'Archive'
       OR (SELECT email FROM users WHERE user_id=7)<>'archive@example.test'
       OR (SELECT count(*) FROM membership_periods WHERE conversation_id=201 AND user_id=2)<>2
       OR (SELECT count(*) FROM conversation_members WHERE conversation_id=201 AND user_id=2)<>1
       OR EXISTS(SELECT 1 FROM conversations c WHERE conversation_type='GROUP' AND
          (SELECT count(*) FROM membership_periods p WHERE p.conversation_id=c.conversation_id AND p.joined_at=c.created_at)<3)
       THEN RAISE EXCEPTION 'B40 fixture policy'; END IF;
    INSERT INTO verification_results VALUES('B','B40','PASS','Fixture-only crypto/password labels, retained identifiers, three initial group members and stable rejoin');
END;
$report_queries$;

-- C: explicit SQL contract simulations only. Every SAVEPOINT is restored before
-- the next case. PASS does not mean the Java application implements the contract.
SAVEPOINT c01;
SELECT user_id FROM users WHERE user_id IN(4,6) ORDER BY user_id FOR UPDATE;
UPDATE friend_requests SET status='ACCEPTED',resolved_at='2026-12-03 10:00:00+07' WHERE request_id=3 AND sender_id=4 AND recipient_id=6 AND status='PENDING';
INSERT INTO friendships(user_low_id,user_high_id,created_at) VALUES(4,6,'2026-12-03 10:00:00+07');
DO $c$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM friendships WHERE user_low_id=4 AND user_high_id=6) OR (SELECT status FROM friend_requests WHERE request_id=3)<>'ACCEPTED' THEN RAISE EXCEPTION 'C01 reciprocal acceptance'; END IF;
END $c$;
ROLLBACK TO SAVEPOINT c01; RELEASE SAVEPOINT c01;
INSERT INTO verification_results VALUES('C','C01','PASS','SQL reciprocal acceptance, restored by rollback');

SAVEPOINT c02;
SELECT user_id FROM users WHERE user_id IN(1,5) ORDER BY user_id FOR UPDATE;
INSERT INTO user_blocks(blocker_id,blocked_id) VALUES(1,5);
DELETE FROM friendships WHERE user_low_id=1 AND user_high_id=5;
UPDATE friend_requests SET status='CANCELLED',resolved_at='2026-12-03 10:00:00+07' WHERE status='PENDING' AND LEAST(sender_id,recipient_id)=1 AND GREATEST(sender_id,recipient_id)=5;
DO $c$ BEGIN
 IF EXISTS(SELECT 1 FROM friendships WHERE user_low_id=1 AND user_high_id=5) OR NOT EXISTS(SELECT 1 FROM user_blocks WHERE blocker_id=1 AND blocked_id=5) THEN RAISE EXCEPTION 'C02 explicit block cleanup'; END IF;
END $c$;
ROLLBACK TO SAVEPOINT c02; RELEASE SAVEPOINT c02;
INSERT INTO verification_results VALUES('C','C02','PASS','SQL block removes friendship; no trigger assumed');

SAVEPOINT c03;
SELECT user_id FROM users WHERE user_id IN(4,6) ORDER BY user_id FOR UPDATE;
INSERT INTO user_blocks(blocker_id,blocked_id) VALUES(4,6);
DELETE FROM friendships WHERE user_low_id=4 AND user_high_id=6;
UPDATE friend_requests SET status='CANCELLED',resolved_at='2026-12-03 10:00:00+07' WHERE status='PENDING' AND LEAST(sender_id,recipient_id)=4 AND GREATEST(sender_id,recipient_id)=6;
DO $c$ BEGIN IF (SELECT status FROM friend_requests WHERE request_id=3)<>'CANCELLED' THEN RAISE EXCEPTION 'C03 request cleanup'; END IF; END $c$;
ROLLBACK TO SAVEPOINT c03; RELEASE SAVEPOINT c03;
INSERT INTO verification_results VALUES('C','C03','PASS','SQL block cancels pending invitation, restored');

SAVEPOINT c04;
SELECT user_id FROM users WHERE user_id IN(1,2,3) ORDER BY user_id FOR UPDATE;
SELECT conversation_id FROM conversations WHERE conversation_id=201 FOR UPDATE;
UPDATE membership_periods SET group_role='ADMIN' WHERE period_id=104 AND left_at IS NULL;
UPDATE membership_periods SET left_at='2026-12-03 10:00:00+07' WHERE period_id=101;
UPDATE group_key_epochs SET epoch_status='CLOSED',ends_at='2026-12-03 10:00:00+07' WHERE conversation_id=201 AND ends_at IS NULL;
INSERT INTO group_key_epochs(key_epoch_id,conversation_id,starts_at) OVERRIDING SYSTEM VALUE VALUES(1004,201,'2026-12-03 10:00:00+07');
DO $c$ BEGIN
 IF (SELECT count(*) FROM membership_periods WHERE conversation_id=201 AND group_role='ADMIN' AND left_at IS NULL)<>1
 OR NOT EXISTS(SELECT 1 FROM membership_periods WHERE period_id=104 AND group_role='ADMIN')
 OR NOT EXISTS(SELECT 1 FROM conversation_members WHERE conversation_id=201 AND user_id=1)
 OR (SELECT epoch_status FROM group_key_epochs WHERE key_epoch_id=1004)<>'PENDING' THEN RAISE EXCEPTION 'C04 transfer/leave/cutover'; END IF;
END $c$;
ROLLBACK TO SAVEPOINT c04; RELEASE SAVEPOINT c04;
INSERT INTO verification_results VALUES('C','C04','PASS','SQL successor transfer before leave; retained stable member and pending epoch');

SAVEPOINT c05;
SELECT user_id FROM users WHERE user_id IN(1,2,3,4,5) ORDER BY user_id FOR UPDATE;
SELECT conversation_id FROM conversations WHERE conversation_id IN(201,203) ORDER BY conversation_id FOR UPDATE;
UPDATE e2ee_devices SET revoked_at='2026-12-03 10:00:00+07' WHERE device_id=12;
INSERT INTO e2ee_devices(device_id,user_id,device_uid,public_key,authorized_at) OVERRIDING SYSTEM VALUE
 VALUES(13,1,'00000000-0000-0000-0000-000000000013',decode('aabb','hex'),'2026-12-03 10:00:00+07');
UPDATE group_key_epochs SET epoch_status='CLOSED',ends_at='2026-12-03 10:00:00+07' WHERE conversation_id IN(201,203) AND ends_at IS NULL;
INSERT INTO group_key_epochs(key_epoch_id,conversation_id,starts_at) OVERRIDING SYSTEM VALUE VALUES
 (1004,201,'2026-12-03 10:00:00+07'),(3002,203,'2026-12-03 10:00:00+07');
DO $c$
DECLARE r record;
BEGIN
 IF (SELECT count(*) FROM e2ee_devices WHERE user_id=1 AND revoked_at IS NULL)<>1
 OR NOT EXISTS(SELECT 1 FROM e2ee_devices WHERE device_id=13 AND revoked_at IS NULL)
 OR EXISTS(SELECT 1 FROM group_key_grants WHERE device_id=13) THEN RAISE EXCEPTION 'C05 device metadata'; END IF;
 FOR r IN EXECUTE $$EXECUTE q_chat_messages(1,13,201,'HISTORY',NULL,NULL,NULL,50)$$ LOOP RAISE EXCEPTION 'C05 new generation fetched old history'; END LOOP;
 FOR r IN EXECUTE $$EXECUTE q_chat_messages(1,12,201,'HISTORY',NULL,NULL,NULL,50)$$ LOOP RAISE EXCEPTION 'C05 revoked device fetched history'; END LOOP;
END $c$;
ROLLBACK TO SAVEPOINT c05; RELEASE SAVEPOINT c05;
INSERT INTO verification_results VALUES('C','C05','PASS','SQL device revoke/new generation and affected-group cutover; no real session/key test');

SAVEPOINT c06;
SELECT user_id FROM users WHERE user_id IN(3,9) ORDER BY user_id FOR UPDATE;
UPDATE users SET account_status='LOCKED' WHERE user_id=3;
UPDATE spam_reports SET status='RESOLVED',resolved_at='2026-12-03 10:00:00+07',resolved_by_user_id=9 WHERE reported_user_id=3;
INSERT INTO admin_audit_log(audit_id,actor_user_id,actor_username_snapshot,actor_full_name_snapshot,operation_id,event_type,outcome,target_user_id,target_report_id,detail)
 OVERRIDING SYSTEM VALUE VALUES(-9061,9,'demo_admin','Demo Admin','00000000-0000-0000-0000-000000009061','SPAM_RESOLVED','SUCCESS',3,4,'prior DISMISSED; DB SQL simulation');
DO $c$
DECLARE r record;
BEGIN
 IF EXISTS(SELECT 1 FROM spam_reports WHERE reported_user_id=3 AND status<>'RESOLVED')
 OR NOT EXISTS(SELECT 1 FROM admin_audit_log WHERE audit_id=-9061 AND detail LIKE 'prior DISMISSED%') THEN RAISE EXCEPTION 'C06 D38 all-report processing/audit'; END IF;
 FOR r IN EXECUTE $$EXECUTE q_chat_messages(3,31,201,'HISTORY',NULL,NULL,NULL,50)$$ LOOP RAISE EXCEPTION 'C06 locked viewer'; END LOOP;
END $c$;
ROLLBACK TO SAVEPOINT c06; RELEASE SAVEPOINT c06;
INSERT INTO verification_results VALUES('C','C06','PASS','SQL lock resolves pending AND dismissed target reports; audit retained; TCP NOT RUN');

-- Boundaries: DB deliberately accepts these business-invalid writes. The
-- canonical read query / explicit contract predicates must reject them.
SAVEPOINT c07;
INSERT INTO conversation_members(conversation_id,user_id) VALUES(101,4);
INSERT INTO membership_periods(period_id,conversation_id,user_id,conversation_type,joined_at)
 OVERRIDING SYSTEM VALUE VALUES(900001,101,4,'PRIVATE','2026-12-03 10:00:00+07');
INSERT INTO messages(message_id,conversation_id,conversation_type,sender_user_id,sender_period_id,text_content,sent_at)
 OVERRIDING SYSTEM VALUE VALUES(900001,101,'PRIVATE',4,900001,'DB boundary fixture','2026-12-03 10:01:00+07');
DO $c$
DECLARE r record;
BEGIN
 IF (SELECT count(*) FROM conversation_members WHERE conversation_id=101)<>3 THEN RAISE EXCEPTION 'C07 expected DB cardinality boundary'; END IF;
 FOR r IN EXECUTE $$EXECUTE q_chat_messages(4,41,101,'HISTORY',NULL,NULL,NULL,50)$$ LOOP RAISE EXCEPTION 'C07 canonical pair read guard'; END LOOP;
END $c$;
ROLLBACK TO SAVEPOINT c07; RELEASE SAVEPOINT c07;
INSERT INTO verification_results VALUES('C','C07','PASS','DB accepts third member; canonical query denies it; writer authorization still required');

SAVEPOINT c08;
INSERT INTO spam_reports(report_id,reporter_id,reported_user_id,reported_at)
 OVERRIDING SYSTEM VALUE VALUES(-9081,1,5,'2026-12-03 10:00:00+07');
DO $c$ BEGIN
 IF EXISTS(SELECT 1 FROM messages m JOIN conversations c USING(conversation_id)
 WHERE c.conversation_type='PRIVATE' AND c.private_user_low_id=1 AND c.private_user_high_id=5 AND m.sender_user_id=5) THEN RAISE EXCEPTION 'C08 fixture should lack incoming evidence'; END IF;
END $c$;
ROLLBACK TO SAVEPOINT c08; RELEASE SAVEPOINT c08;
INSERT INTO verification_results VALUES('C','C08','PASS','DB does not enforce incoming spam evidence; application predicate is false');

SAVEPOINT c09;
INSERT INTO group_key_grants(key_epoch_id,device_id,conversation_id,user_id,period_id,wrapped_key,granted_at)
 VALUES(3001,12,203,1,301,decode('bb99','hex'),'2026-12-03 10:00:00+07');
INSERT INTO messages(message_id,conversation_id,conversation_type,sender_user_id,sender_period_id,ciphertext,payload_version,key_epoch_id,sender_device_id,sent_at)
 OVERRIDING SYSTEM VALUE VALUES(900003,203,'GROUP',1,301,decode('cc99','hex'),1,3001,12,'2026-12-03 10:01:00+07');
DO $c$
DECLARE r record;
BEGIN
 IF (SELECT epoch_status FROM group_key_epochs WHERE key_epoch_id=3001)<>'PENDING' THEN RAISE EXCEPTION 'C09 pending fixture'; END IF;
 FOR r IN EXECUTE $$EXECUTE q_chat_messages(1,12,203,'HISTORY',NULL,NULL,NULL,50)$$ LOOP RAISE EXCEPTION 'C09 pending history read'; END LOOP;
END $c$;
ROLLBACK TO SAVEPOINT c09; RELEASE SAVEPOINT c09;
INSERT INTO verification_results VALUES('C','C09','PASS','DB FK permits PENDING write; read/ACTIVE application guards required, no hidden trigger');

SAVEPOINT c10;
DO $c$
DECLARE changed integer;
BEGIN
 UPDATE conversations SET group_name='Forbidden non-admin rename' WHERE conversation_id=201 AND EXISTS
 (SELECT 1 FROM membership_periods p WHERE p.conversation_id=201 AND p.user_id=3 AND p.left_at IS NULL AND p.group_role='ADMIN');
 GET DIAGNOSTICS changed=ROW_COUNT;
 IF changed<>0 THEN RAISE EXCEPTION 'C10 non-admin rename guard'; END IF;
 UPDATE conversations SET group_name='Allowed SQL contract rename' WHERE conversation_id=201 AND EXISTS
 (SELECT 1 FROM membership_periods p WHERE p.conversation_id=201 AND p.user_id=1 AND p.left_at IS NULL AND p.group_role='ADMIN');
 GET DIAGNOSTICS changed=ROW_COUNT;
 IF changed<>1 OR (SELECT count(DISTINCT x) FROM unnest(ARRAY[1,2,2]) x)>=3
 OR (SELECT count(DISTINCT x) FROM unnest(ARRAY[1,2,3]) x)<3 THEN RAISE EXCEPTION 'C10 role/minimum-size predicates'; END IF;
END $c$;
ROLLBACK TO SAVEPOINT c10; RELEASE SAVEPOINT c10;
INSERT INTO verification_results VALUES('C','C10','PASS','SQL role and distinct-three predicates; actual application NOT RUN');

SAVEPOINT c11;
SELECT user_id FROM users WHERE user_id IN(1,4,5) ORDER BY user_id FOR UPDATE;
SELECT conversation_id FROM conversations WHERE conversation_id=203 FOR UPDATE;
UPDATE membership_periods SET left_at='2026-12-03 10:00:00+07' WHERE period_id IN(302,303);
DO $c$ BEGIN
 IF EXISTS(SELECT 1 FROM membership_periods p JOIN users u USING(user_id) WHERE p.conversation_id=203 AND p.user_id<>1 AND p.left_at IS NULL AND u.account_status='ACTIVE' AND u.deleted_at IS NULL) THEN RAISE EXCEPTION 'C11 successor should be absent'; END IF;
END $c$;
UPDATE conversations SET closed_at='2026-12-03 10:00:00+07' WHERE conversation_id=203;
UPDATE group_key_epochs SET epoch_status='CLOSED',ends_at='2026-12-03 10:00:00+07' WHERE conversation_id=203 AND ends_at IS NULL;
UPDATE membership_periods SET left_at='2026-12-03 10:00:00+07' WHERE period_id=301;
DO $c$ BEGIN
 IF (SELECT count(*) FROM conversation_members WHERE conversation_id=203)<>3
 OR EXISTS(SELECT 1 FROM group_key_epochs WHERE conversation_id=203 AND ends_at IS NULL)
 OR EXISTS(SELECT 1 FROM conversations WHERE conversation_id=203 AND closed_at IS NULL)
 OR (SELECT count(*) FROM messages WHERE conversation_id=202)<>2 THEN RAISE EXCEPTION 'C11 close/retention'; END IF;
END $c$;
ROLLBACK TO SAVEPOINT c11; RELEASE SAVEPOINT c11;
INSERT INTO verification_results VALUES('C','C11','PASS','SQL exceptional closure before last-admin leave; data retained, rollback restored');

INSERT INTO verification_results VALUES('D','D01','NOT RUN','No real application/session/TCP/crypto/codec execution; fixture bytes prove storage only');
DO $summary$
BEGIN
 IF (SELECT count(*) FROM verification_results WHERE category='A' AND result='PASS')<>48
 OR (SELECT count(*) FROM verification_results WHERE category='B' AND result='PASS')<>40
 OR (SELECT count(*) FROM verification_results WHERE category='C' AND result='PASS')<>11 THEN RAISE EXCEPTION 'Incomplete A/B/C coverage'; END IF;
END $summary$;
SELECT category,result,count(*) AS cases FROM verification_results GROUP BY category,result ORDER BY category,result;
ROLLBACK;
SELECT md5(jsonb_build_object(
'users',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.user_id) FROM users t),
'login_history',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.login_id) FROM login_history t),
'friend_requests',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.request_id) FROM friend_requests t),
'friendships',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.user_low_id,t.user_high_id) FROM friendships t),
'user_blocks',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.blocker_id,t.blocked_id) FROM user_blocks t),
'conversations',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.conversation_id) FROM conversations t),
'conversation_members',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.conversation_id,t.user_id) FROM conversation_members t),
'membership_periods',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.period_id) FROM membership_periods t),
'e2ee_devices',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.device_id) FROM e2ee_devices t),
'group_key_epochs',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.key_epoch_id) FROM group_key_epochs t),
'group_key_grants',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.key_epoch_id,t.device_id) FROM group_key_grants t),
'messages',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.message_id) FROM messages t),
'message_hidden',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.message_id,t.user_id) FROM message_hidden t),
'spam_reports',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.report_id) FROM spam_reports t),
'admin_audit_log',(SELECT jsonb_agg(to_jsonb(t) ORDER BY t.audit_id) FROM admin_audit_log t),
'sequences',(SELECT jsonb_object_agg(sequencename,last_value) FROM pg_sequences WHERE schemaname='public'))::text) = :'before_fingerprint' AS fixture_unchanged \gset
\if :fixture_unchanged
\echo 'PASS: complete fixture and identity-sequence fingerprint preserved after verification rollback'
\else
DO $fail$ BEGIN RAISE EXCEPTION 'Verification changed fixture/sequence state'; END $fail$;
\endif
