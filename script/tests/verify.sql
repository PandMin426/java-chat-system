-- Run after schema.sql and seed.sql on a dedicated test database.
-- Assertions abort on unexpected SQLSTATE or result; changes are rolled back.
BEGIN;

CREATE FUNCTION pg_temp.expect_failure(statement text, expected_state text) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE statement;
    RAISE EXCEPTION 'Expected SQLSTATE % for %', expected_state, statement;
EXCEPTION WHEN OTHERS THEN
    IF SQLSTATE <> expected_state THEN RAISE; END IF;
END;
$$;

DO $$
DECLARE
    a bigint := (SELECT user_id FROM users WHERE username = 'Minh');
    b bigint := (SELECT user_id FROM users WHERE username = 'Trang');
    c bigint := (SELECT user_id FROM users WHERE username = 'Binh');
    d bigint := (SELECT user_id FROM users WHERE username = 'minh');
    original bigint := (SELECT user_id FROM users WHERE account_status = 'DELETED');
    replacement bigint := (SELECT user_id FROM users WHERE username = 'archive');
    chat bigint := (SELECT conversation_id FROM private_conversations WHERE user_low_id = a AND user_high_id = b);
    msg bigint := (SELECT private_message_id FROM private_message_hides WHERE user_id = a);
    team bigint := (SELECT group_id FROM chat_groups WHERE group_name = 'Nhóm V1');
    closed_team bigint := (SELECT group_id FROM chat_groups WHERE group_name = 'Nhóm lưu trữ');
    a_member bigint := (SELECT membership_id FROM group_memberships WHERE group_id = team AND user_id = a AND left_at IS NULL);
    old_b_member bigint := (SELECT membership_id FROM group_memberships WHERE group_id = team AND user_id = b AND left_at IS NOT NULL);
    closed_member bigint := (SELECT membership_id FROM group_memberships WHERE group_id = closed_team AND user_id = c);
    old_device bigint := (SELECT device_id FROM e2ee_devices WHERE user_id = a AND revoked_at IS NOT NULL);
    new_device bigint := (SELECT device_id FROM e2ee_devices WHERE user_id = a AND revoked_at IS NULL);
    b_device bigint := (SELECT device_id FROM e2ee_devices WHERE user_id = b);
    epoch bigint := (SELECT key_epoch_id FROM group_key_epochs WHERE group_id = team AND ends_at IS NULL);
    first_epoch bigint := (SELECT key_epoch_id FROM group_key_epochs WHERE group_id = team ORDER BY starts_at LIMIT 1);
    closed_epoch bigint;
    c_member bigint;
    c_device bigint;
    request_id bigint;
    table_name text;
    actual_tables text[];
    row_count bigint;
    direct_count bigint;
    expanded_count bigint;
    period_start CONSTANT timestamptz := '2026-11-01 00:00:00 Asia/Ho_Chi_Minh';
    period_end CONSTANT timestamptz := '2026-12-01 00:00:00 Asia/Ho_Chi_Minh';
BEGIN
    SELECT array_agg(tablename::text ORDER BY tablename) INTO actual_tables
    FROM pg_tables WHERE schemaname = 'public';
    IF actual_tables IS DISTINCT FROM ARRAY['app_open_events','chat_groups','e2ee_devices','friend_requests',
        'friendships','group_key_epochs','group_key_grants','group_memberships','group_messages','login_events',
        'private_conversations','private_message_hides','private_messages','spam_reports','user_blocks','users'] THEN
        RAISE EXCEPTION 'Unexpected table inventory: %', actual_tables;
    END IF;
    IF (SELECT count(*) FROM information_schema.table_constraints
        WHERE table_schema = 'public' AND constraint_type = 'PRIMARY KEY') <> 16 THEN
        RAISE EXCEPTION 'Each table must have a primary key';
    END IF;
    FOREACH table_name IN ARRAY actual_tables LOOP
        EXECUTE format('SELECT count(*) FROM %I', table_name) INTO row_count;
        IF row_count = 0 THEN RAISE EXCEPTION 'Missing seed data for %', table_name; END IF;
    END LOOP;
    RAISE NOTICE 'PASS: exact 16-table inventory, all primary keys, fixture coverage';

    IF a IS NULL OR d IS NULL OR a = d OR (SELECT email FROM users WHERE user_id = a) <> 'Minh@example.test' THEN
        RAISE EXCEPTION 'Username case sensitivity or email trimming failed';
    END IF;
    PERFORM pg_temp.expect_failure(format('UPDATE users SET email=%L WHERE user_id=%s',' MINH@example.test ',d),'23505');
    PERFORM pg_temp.expect_failure(format('UPDATE users SET account_status=%L WHERE user_id=%s','INVALID',a),'23514');
    PERFORM pg_temp.expect_failure(format('UPDATE users SET created_at=created_at + interval %L WHERE user_id=%s','1 day',a),'23514');
    PERFORM pg_temp.expect_failure(format('UPDATE users SET registration_source=%L WHERE user_id=%s','INTERNAL',a),'23514');
    PERFORM pg_temp.expect_failure(format('UPDATE users SET account_status=%L WHERE user_id=%s','DELETED',a),'23514');
    PERFORM pg_temp.expect_failure(format('UPDATE users SET account_status=%L WHERE user_id=%s','ACTIVE',original),'23514');
    PERFORM pg_temp.expect_failure(format('DELETE FROM users WHERE user_id=%s',d),'23514');
    PERFORM pg_temp.expect_failure('INSERT INTO login_events(user_id) VALUES (-1)','23503');
    PERFORM pg_temp.expect_failure('INSERT INTO app_open_events(user_id) VALUES (-1)','23503');
    IF original IS NULL OR replacement IS NULL OR original = replacement
        OR (SELECT email FROM users WHERE user_id = replacement) <> 'ARCHIVE@example.test'
        OR NOT EXISTS (SELECT FROM login_events WHERE user_id = original)
        OR NOT EXISTS (SELECT FROM private_messages WHERE sender_id = original)
        OR NOT EXISTS (SELECT FROM spam_reports WHERE reported_user_id = original)
        OR NOT EXISTS (SELECT FROM group_memberships WHERE user_id = original AND left_at IS NOT NULL) THEN
        RAISE EXCEPTION 'Soft delete did not preserve history or allow identifier reuse';
    END IF;
    RAISE NOTICE 'PASS: Core constraints, immutable registration metadata, soft delete and history';

    PERFORM pg_temp.expect_failure(format('INSERT INTO friend_requests(sender_id,recipient_id) VALUES (%s,%s)',a,a),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO friend_requests(sender_id,recipient_id) VALUES (%s,%s)',c,a),'23505');
    PERFORM pg_temp.expect_failure(format('INSERT INTO friend_requests(sender_id,recipient_id,request_status,resolved_at) VALUES (%s,%s,%L,CURRENT_TIMESTAMP)',a,d,'ACCEPTED'),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO friendships VALUES (%s,%s)',b,a),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO friendships VALUES (%s,%s)',a,b),'23505');
    PERFORM pg_temp.expect_failure(format('INSERT INTO user_blocks VALUES (%s,%s)',a,a),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO friend_requests(sender_id,recipient_id) VALUES (%s,%s)',d,c),'23514');
    IF NOT EXISTS (SELECT FROM friend_requests WHERE sender_id = d AND recipient_id = c AND request_status = 'CANCELLED') THEN
        RAISE EXCEPTION 'Block did not cancel the pending request';
    END IF;
    PERFORM lock_social_pair(a,c);
    UPDATE friend_requests SET request_status = 'ACCEPTED', resolved_at = GREATEST(requested_at, CURRENT_TIMESTAMP)
    WHERE sender_id = a AND recipient_id = c AND request_status = 'PENDING' RETURNING friend_request_id INTO request_id;
    IF request_id IS NULL THEN RAISE EXCEPTION 'Missing pending request for acceptance'; END IF;
    INSERT INTO friendships VALUES (a,c);
    INSERT INTO friend_requests(sender_id,recipient_id) VALUES (c,a);
    INSERT INTO user_blocks VALUES (a,c);
    IF EXISTS (SELECT FROM friendships WHERE user_low_id = a AND user_high_id = c)
        OR NOT EXISTS (SELECT FROM friend_requests WHERE sender_id = c AND recipient_id = a AND request_status = 'CANCELLED')
        OR NOT EXISTS (SELECT FROM friend_requests WHERE friend_request_id = request_id AND request_status = 'ACCEPTED') THEN
        RAISE EXCEPTION 'Acceptance or block cleanup left inconsistent data';
    END IF;
    RAISE NOTICE 'PASS: social pair constraints, PENDING rules, acceptance transaction and block cleanup';

    PERFORM pg_temp.expect_failure(format('INSERT INTO private_conversations(user_low_id,user_high_id) VALUES (%s,%s)',a,b),'23505');
    PERFORM pg_temp.expect_failure(format('UPDATE private_conversations SET user_high_id=%s WHERE conversation_id=%s',c,chat),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO private_messages(conversation_id,sender_id,content) VALUES (%s,%s,%L)',chat,c,'Outsider'),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO private_message_hides VALUES (%s,%s)',msg,c),'23514');
    PERFORM pg_temp.expect_failure(format('DELETE FROM private_messages WHERE private_message_id=%s',msg),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO spam_reports(reporter_id,reported_user_id) VALUES (%s,%s)',a,d),'23514');
    IF (SELECT count(*) FROM spam_reports WHERE reporter_id = a AND reported_user_id = b) <> 2
        OR NOT EXISTS (SELECT FROM private_messages WHERE private_message_id = msg)
        OR EXISTS (SELECT FROM private_message_hides WHERE private_message_id = msg AND user_id = b) THEN
        RAISE EXCEPTION 'Per-user hide or duplicate spam report rule failed';
    END IF;
    INSERT INTO user_blocks VALUES (a,b);
    PERFORM pg_temp.expect_failure(format('INSERT INTO private_messages(conversation_id,sender_id,content) VALUES (%s,%s,%L)',chat,a,'Blocked'),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO private_messages(conversation_id,sender_id,content) VALUES (%s,%s,%L)',chat,b,'Blocked'),'23514');
    RAISE NOTICE 'PASS: private conversation, participants, per-user hides, two-way message block and spam eligibility';

    PERFORM pg_temp.expect_failure(format('INSERT INTO group_memberships(group_id,user_id) VALUES (%s,%s)',team,a),'23505');
    PERFORM pg_temp.expect_failure(format('INSERT INTO group_key_epochs(group_id) VALUES (%s)',team),'23505');
    PERFORM pg_temp.expect_failure(format('INSERT INTO e2ee_devices(user_id,public_key) VALUES (%s,decode(%L,%L))',a,'01','hex'),'23505');
    PERFORM pg_temp.expect_failure(format('INSERT INTO group_messages(group_id,key_epoch_id,sender_membership_id,encrypted_payload) VALUES (%s,%s,%s,decode(%L,%L))',team,epoch,closed_member,'01','hex'),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO group_messages(group_id,key_epoch_id,sender_membership_id,encrypted_payload) VALUES (%s,%s,%s,decode(%L,%L))',team,epoch,old_b_member,'01','hex'),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO group_messages(group_id,key_epoch_id,sender_membership_id,encrypted_payload) VALUES (%s,%s,%s,decode(%L,%L))',team,first_epoch,a_member,'01','hex'),'23514');
    INSERT INTO group_key_epochs(group_id) VALUES (closed_team) RETURNING key_epoch_id INTO closed_epoch;
    PERFORM pg_temp.expect_failure(format('INSERT INTO group_messages(group_id,key_epoch_id,sender_membership_id,encrypted_payload) VALUES (%s,%s,%s,decode(%L,%L))',team,closed_epoch,a_member,'01','hex'),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO group_messages(group_id,key_epoch_id,sender_membership_id,encrypted_payload) VALUES (%s,%s,%s,decode(%L,%L))',closed_team,closed_epoch,closed_member,'01','hex'),'23514');
    IF (SELECT count(*) FROM group_memberships WHERE group_id = team AND user_id = b) <> 2
        OR (SELECT count(*) FROM group_messages WHERE group_id = team) <> 3 THEN
        RAISE EXCEPTION 'Membership or group-message history was lost';
    END IF;
    RAISE NOTICE 'PASS: group scope, membership/epoch uniqueness and history, rejection of ended or closed state';

    -- Use the wrong user_id on an existing grant update so PK duplication cannot mask the owner FK.
    PERFORM pg_temp.expect_failure(format('UPDATE group_key_grants SET user_id=%s WHERE key_epoch_id=%s AND device_id=%s',b,epoch,new_device),'23503');
    PERFORM pg_temp.expect_failure(format('UPDATE group_key_grants SET membership_id=%s WHERE key_epoch_id=%s AND device_id=%s',a_member,epoch,b_device),'23503');
    PERFORM pg_temp.expect_failure(format('UPDATE e2ee_devices SET user_id=%s WHERE device_id=%s',c,new_device),'23503');
    PERFORM pg_temp.expect_failure(format('INSERT INTO group_key_grants VALUES (%s,%s,%s,%s,%s,decode(%L,%L))',epoch,old_device,team,a_member,a,'01','hex'),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO group_key_grants VALUES (%s,%s,%s,%s,%s,decode(%L,%L))',first_epoch,new_device,team,a_member,a,'01','hex'),'23514');
    INSERT INTO group_memberships(group_id,user_id,joined_at) VALUES (team,c,period_start) RETURNING membership_id INTO c_member;
    INSERT INTO e2ee_devices(user_id,public_key,authorized_at)
    VALUES (c,decode('01','hex'),period_start + interval '3 hours') RETURNING device_id INTO c_device;
    PERFORM pg_temp.expect_failure(format('INSERT INTO group_key_grants VALUES (%s,%s,%s,%s,%s,decode(%L,%L))',epoch,c_device,team,c_member,c,'01','hex'),'23514');
    UPDATE e2ee_devices SET authorized_at = period_start WHERE device_id = c_device;
    UPDATE group_memberships SET joined_at = period_start + interval '3 hours' WHERE membership_id = c_member;
    PERFORM pg_temp.expect_failure(format('INSERT INTO group_key_grants VALUES (%s,%s,%s,%s,%s,decode(%L,%L))',epoch,c_device,team,c_member,c,'01','hex'),'23514');
    PERFORM pg_temp.expect_failure(format('INSERT INTO group_messages(group_id,key_epoch_id,sender_membership_id,encrypted_payload,sent_at) VALUES (%s,%s,%s,decode(%L,%L),%L)',team,epoch,c_member,'01','hex',period_start + interval '4 hours'),'23514');
    IF (SELECT count(*) FROM group_key_grants WHERE device_id = old_device) <> 1
        OR (SELECT count(*) FROM group_key_grants WHERE device_id = new_device) <> 2 THEN
        RAISE EXCEPTION 'Existing device grants did not preserve epoch history';
    END IF;
    RAISE NOTICE 'PASS: E2EE grant ownership, active scope, no backward grant or stale send, retained historical grants';

    -- Undo the two blocks created by this test by rolling the outer transaction back
    -- after checking reports. The original fixture has Minh -> Trang -> Binh.
    WITH edges AS (
        SELECT user_low_id AS src, user_high_id AS dst FROM friendships
        UNION ALL SELECT user_high_id, user_low_id FROM friendships
    ), direct AS (SELECT dst FROM edges WHERE src = b), expanded AS (
        SELECT dst FROM direct UNION SELECT e.dst FROM edges e JOIN direct d1 ON e.src = d1.dst WHERE e.dst <> b
    )
    SELECT (SELECT count(*) FROM direct),(SELECT count(*) FROM expanded) INTO direct_count,expanded_count;
    IF direct_count <> 1 OR expanded_count <> 1 THEN RAISE EXCEPTION 'Friend summary after block failed'; END IF;
    IF (SELECT count(*) FROM users WHERE registration_source='SELF_REGISTERED' AND created_at >= period_start AND created_at < period_end) <> 3
        OR (SELECT count(*) FROM app_open_events WHERE opened_at >= period_start AND opened_at < period_end) <> 3
        OR (SELECT count(DISTINCT user_id) FROM app_open_events WHERE opened_at >= period_start AND opened_at < period_end) <> 2
        OR (SELECT count(DISTINCT m.group_id) FROM group_messages m JOIN group_memberships gm ON gm.membership_id=m.sender_membership_id
            WHERE gm.user_id=a AND m.sent_at >= period_start AND m.sent_at < period_end) <> 1
        OR (SELECT count(DISTINCT CASE WHEN p.user_low_id=a THEN p.user_high_id ELSE p.user_low_id END)
            FROM private_messages m JOIN private_conversations p USING (conversation_id)
            WHERE m.sender_id=a AND m.sent_at >= period_start AND m.sent_at < period_end) <> 1 THEN
        RAISE EXCEPTION 'Registration/activity query or Vietnam-time boundary failed';
    END IF;
    IF (SELECT count(*) FROM private_messages m WHERE m.conversation_id=chat AND strpos(lower(m.content),lower('HÒA')) > 0
        AND NOT EXISTS (SELECT FROM private_message_hides h WHERE h.private_message_id=m.private_message_id AND h.user_id=b)) <> 1
        OR EXISTS (SELECT FROM private_messages m WHERE m.conversation_id=chat AND strpos(lower(m.content),lower('HÒA')) > 0
        AND NOT EXISTS (SELECT FROM private_message_hides h WHERE h.private_message_id=m.private_message_id AND h.user_id=a))
        OR (SELECT count(*) FROM private_messages WHERE conversation_id=chat AND strpos(lower(content),lower('Hoa')) > 0) <> 1 THEN
        RAISE EXCEPTION 'Case-insensitive, accent-sensitive history search failed';
    END IF;
    RAISE NOTICE 'PASS: reporting queries, Vietnam-time boundaries, and accent-sensitive per-user history search';
END;
$$;

ROLLBACK;
