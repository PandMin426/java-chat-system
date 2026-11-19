-- Parameterized, session-scoped queries; no helper function, trigger or view.
-- Load with psql -v test_db=EXACT_NAME -f queries.sql, then EXECUTE in the SAME
-- session. verify.sql loads this file with \ir. Authenticated identities/device
-- proof must come from the server; passing an ID is not authentication.
-- Q02-Q07 admin/report metadata require upstream system-ADMIN authorization.
-- Q08 is UserApp search; Q09 requires the caller's appropriate admin/group role.
\set ON_ERROR_STOP on
SELECT set_config('jcs.test_db', :'test_db', false);
DO $guard$
BEGIN
    IF current_database() <> current_setting('jcs.test_db')
       OR current_database() !~ '^jcs_schema_test_[0-9]{8}_[0-9]{6}_[0-9a-f]{6}$' THEN
        RAISE EXCEPTION 'Query examples require the explicitly named dedicated test DB';
    END IF;
END;
$guard$;

-- Q01 canonical visibility, shared by HISTORY, SEARCH, AROUND and keyset pages.
-- Parameters: viewer, current device (NULL allowed for PRIVATE), conversation
-- (NULL for global PRIVATE search/history), mode, before-visible-ID, literal
-- search text, visible anchor ID, page size (default 50, clamped 1..50).
-- HISTORY/SEARCH descending ID; AROUND ascending, centered on VISIBLE rows.
-- Search only PRIVATE plaintext. '%' and '_' are literal substring characters.
-- Existing block/closure do not erase historical rights. Revoked/new device
-- generations cannot fetch old grants. Closed member periods can retain rights.
-- Unread excludes own messages and is computed BEFORE pagination/search, AFTER
-- visibility. Wrapped bytes returned here are fixtures, not real decryption.
-- Examples / expected IDs:
-- EXECUTE q_chat_messages(1,12,101,'HISTORY',NULL,NULL,NULL,50); -> 6,5,4 (unread=1)
-- EXECUTE q_chat_messages(1,12,101,'SEARCH',NULL,'ALPHA',NULL,50); -> 6,4
-- EXECUTE q_chat_messages(1,12,101,'HISTORY',5,NULL,NULL,50); -> 4
-- EXECUTE q_chat_messages(1,12,101,'AROUND',NULL,NULL,5,3); -> 4,5,6
-- EXECUTE q_chat_messages(2,21,201,'HISTORY',NULL,NULL,NULL,50); -> 1005,1004,1001
-- EXECUTE q_chat_messages(1,12,201,'HISTORY',NULL,NULL,NULL,50); -> 1005,1004,1003
-- EXECUTE q_chat_messages(4,41,202,'HISTORY',NULL,NULL,NULL,50); -> 2002,2001
PREPARE q_chat_messages(bigint,bigint,bigint,text,bigint,text,bigint,integer) AS
WITH p AS (
    SELECT $1 AS viewer_id,$2 AS device_id,$3 AS conv_id,upper(coalesce($4,'HISTORY')) AS mode,
           $5 AS before_id,$6 AS needle,$7 AS anchor_id,
           LEAST(GREATEST(coalesce($8,50),1),50) AS page_size
), visible_base AS (
    SELECT m.*,own.last_read_message_id,
           kg.wrapped_key AS viewer_wrapped_key,kg.envelope_version AS viewer_envelope_version,
           (m.sender_user_id<>p.viewer_id AND m.message_id>coalesce(own.last_read_message_id,0)) AS is_unread
    FROM messages m JOIN conversations c USING(conversation_id) CROSS JOIN p
    JOIN conversation_members own ON own.conversation_id=m.conversation_id AND own.user_id=p.viewer_id
    JOIN users viewer ON viewer.user_id=own.user_id AND viewer.account_status='ACTIVE' AND viewer.deleted_at IS NULL
    LEFT JOIN LATERAL (
        SELECT g.device_id,g.wrapped_key,g.envelope_version
        FROM group_key_grants g
        JOIN e2ee_devices d ON d.device_id=g.device_id AND d.user_id=g.user_id
        JOIN membership_periods vp ON vp.conversation_id=g.conversation_id AND vp.user_id=g.user_id AND vp.period_id=g.period_id
        JOIN group_key_epochs e ON e.conversation_id=g.conversation_id AND e.key_epoch_id=g.key_epoch_id
        WHERE g.conversation_id=m.conversation_id AND g.key_epoch_id=m.key_epoch_id
          AND g.user_id=p.viewer_id AND g.device_id=p.device_id AND d.revoked_at IS NULL
          AND e.epoch_status IN ('ACTIVE','CLOSED') AND e.activated_at IS NOT NULL
          AND e.starts_at>=vp.joined_at AND e.starts_at>=d.authorized_at
          AND g.granted_at>=e.starts_at AND g.granted_at<=e.activated_at
          AND m.sent_at>=e.activated_at AND (e.ends_at IS NULL OR m.sent_at<e.ends_at)
          AND m.sent_at>=vp.joined_at AND (vp.left_at IS NULL OR m.sent_at<vp.left_at)
    ) kg ON c.conversation_type='GROUP'
    WHERE (p.conv_id IS NULL OR m.conversation_id=p.conv_id)
      AND (own.cleared_through_message_id IS NULL OR m.message_id>own.cleared_through_message_id)
      AND NOT EXISTS (SELECT 1 FROM message_hidden h WHERE h.conversation_id=m.conversation_id AND h.message_id=m.message_id AND h.user_id=p.viewer_id)
      AND (c.closed_at IS NULL OR m.sent_at<c.closed_at)
      AND ((c.conversation_type='PRIVATE' AND p.viewer_id IN(c.private_user_low_id,c.private_user_high_id))
           OR (c.conversation_type='GROUP' AND kg.device_id IS NOT NULL))
), visible AS (
    SELECT v.*,count(*) FILTER(WHERE is_unread) OVER(PARTITION BY conversation_id) AS visible_unread_count
    FROM visible_base v
), candidates AS (
    SELECT v.* FROM visible v CROSS JOIN p
    WHERE p.mode<>'SEARCH' OR (p.needle IS NOT NULL AND p.needle<>''
          AND v.conversation_type='PRIVATE' AND strpos(lower(v.text_content),lower(p.needle))>0)
), ranked AS (
    SELECT v.*,row_number() OVER(PARTITION BY conversation_id ORDER BY message_id) AS visible_position
    FROM candidates v
)
SELECT r.message_id,r.conversation_id,r.conversation_type,r.sender_user_id,r.sender_period_id,
       r.sent_at,r.text_content,r.ciphertext,r.payload_version,r.key_epoch_id,r.sender_device_id,
       r.viewer_wrapped_key,r.viewer_envelope_version,r.is_unread,r.visible_unread_count
FROM ranked r CROSS JOIN p
WHERE (p.mode IN ('HISTORY','SEARCH')
       AND (p.before_id IS NULL OR EXISTS(SELECT 1 FROM candidates k WHERE k.message_id=p.before_id))
       AND (p.before_id IS NULL OR r.message_id<p.before_id))
   OR (p.mode='AROUND' AND p.conv_id IS NOT NULL AND EXISTS(
       SELECT 1 FROM ranked a WHERE a.message_id=p.anchor_id AND a.conversation_id=p.conv_id
       AND r.conversation_id=a.conversation_id
       AND r.visible_position BETWEEN a.visible_position-((p.page_size-1)/2)
                                  AND a.visible_position+(p.page_size-1-((p.page_size-1)/2))))
ORDER BY CASE WHEN p.mode='AROUND' THEN r.message_id END ASC,
         CASE WHEN p.mode<>'AROUND' THEN r.message_id END DESC
LIMIT (SELECT page_size FROM p);

-- Q02 viewer-independent admin friend graph: direct vs ONLY level-two.
-- EXECUTE q_friend_counts(1); -> user 1 direct=3, level_two=2 ({4,6})
-- EXECUTE q_friend_counts(10); -> 0,0. NULL selects all users, retained identities included.
PREPARE q_friend_counts(bigint) AS
WITH edges AS (
    SELECT user_low_id AS src,user_high_id AS dst FROM friendships
    UNION ALL SELECT user_high_id,user_low_id FROM friendships
)
SELECT u.user_id,u.username,
       (SELECT count(*) FROM edges d WHERE d.src=u.user_id) AS direct_count,
       (SELECT count(DISTINCT e2.dst) FROM edges e1 JOIN edges e2 ON e2.src=e1.dst
        WHERE e1.src=u.user_id AND e2.dst<>u.user_id
        AND NOT EXISTS(SELECT 1 FROM edges direct WHERE direct.src=u.user_id AND direct.dst=e2.dst)) AS level_two_count
FROM users u WHERE $1 IS NULL OR u.user_id=$1 ORDER BY u.user_id;

-- Q03 admin login history: user (NULL=all), inclusive Vietnam-local date range.
-- EXECUTE q_login_history(1,'2026-11-01','2026-11-30'); -> login IDs 3,2;
-- ID 2 keeps 'Minh Original', although users.full_name is 'Minh Updated'.
PREPARE q_login_history(bigint,date,date) AS
SELECT login_id,user_id,logged_in_at,username_snapshot,full_name_snapshot,remote_ip
FROM login_history
WHERE ($1 IS NULL OR user_id=$1)
  AND logged_in_at>=($2::timestamp AT TIME ZONE 'Asia/Ho_Chi_Minh')
  AND logged_in_at<((($3+1)::timestamp) AT TIME ZONE 'Asia/Ho_Chi_Minh')
ORDER BY logged_in_at DESC,login_id DESC;

-- Q04 12 months, distinct UserApp users (not number of login rows).
-- EXECUTE q_activity_monthly(2026); -> Jan-Sep 0; Oct 2; Nov 4; Dec 3.
PREPARE q_activity_monthly(integer) AS
WITH months AS (
    SELECT n AS month_number,make_date($1,n,1)::timestamp AT TIME ZONE 'Asia/Ho_Chi_Minh' AS lo,
           (make_date($1,n,1)::timestamp+interval '1 month') AT TIME ZONE 'Asia/Ho_Chi_Minh' AS hi
    FROM generate_series(1,12) n
)
SELECT month_number,count(DISTINCT l.user_id) AS active_users
FROM months m LEFT JOIN login_history l ON l.logged_in_at>=m.lo AND l.logged_in_at<m.hi
GROUP BY month_number ORDER BY month_number;

-- Q05 O3 active population requires a UserApp success; received-only messages
-- do not count a sent-to target. Hiding/clear/deletion never remove source events.
-- EXECUTE q_activity(NULL,'2026-11-01','2026-11-30'); -> uid:opens:private:groups
-- 1:2:3:1, 2:2:2:1, 3:1:1:1, 7:1:1:1. Admin 9 and message-only user 4 excluded.
PREPARE q_activity(bigint,date,date) AS
WITH bounds AS (
    SELECT $2::timestamp AT TIME ZONE 'Asia/Ho_Chi_Minh' AS lo,
           ($3+1)::timestamp AT TIME ZONE 'Asia/Ho_Chi_Minh' AS hi
), logins AS (
    SELECT l.user_id,count(*) AS app_opens FROM login_history l CROSS JOIN bounds b
    WHERE l.logged_in_at>=b.lo AND l.logged_in_at<b.hi AND ($1 IS NULL OR l.user_id=$1)
    GROUP BY l.user_id
), sends AS (
    SELECT m.sender_user_id AS user_id,
           count(DISTINCT CASE WHEN m.conversation_type='PRIVATE'
             THEN CASE WHEN c.private_user_low_id=m.sender_user_id THEN c.private_user_high_id ELSE c.private_user_low_id END END) AS private_people,
           count(DISTINCT CASE WHEN m.conversation_type='GROUP' THEN m.conversation_id END) AS groups_sent
    FROM messages m JOIN conversations c USING(conversation_id) CROSS JOIN bounds b
    WHERE m.sent_at>=b.lo AND m.sent_at<b.hi AND ($1 IS NULL OR m.sender_user_id=$1)
    GROUP BY m.sender_user_id
)
SELECT u.user_id,u.username,u.full_name,l.app_opens,
       coalesce(s.private_people,0) AS private_people,coalesce(s.groups_sent,0) AS groups_sent
FROM logins l JOIN users u USING(user_id) LEFT JOIN sends s USING(user_id) ORDER BY u.user_id;

-- Q06 self registrations; November includes its very last microsecond, not Dec 1.
-- EXECUTE q_new_users('2026-11-01','2026-11-30'); -> user IDs 2,3,4,6.
PREPARE q_new_users(date,date) AS
SELECT user_id,username,full_name,created_at,deleted_at FROM users
WHERE registration_source='SELF_REGISTERED'
  AND created_at>=($1::timestamp AT TIME ZONE 'Asia/Ho_Chi_Minh')
  AND created_at<(($2+1)::timestamp AT TIME ZONE 'Asia/Ho_Chi_Minh')
ORDER BY created_at,user_id;

-- Q07 moderation metadata: target (NULL=all), status (NULL=all), local dates.
-- EXECUTE q_spam_list(NULL,'PENDING','2026-11-01','2026-11-30'); -> report IDs 5,2,1.
-- EXECUTE q_spam_list(3,NULL,'2026-11-01','2026-11-30'); -> 5,4.
PREPARE q_spam_list(bigint,text,date,date) AS
SELECT r.report_id,r.reporter_id,r.reported_user_id,u.username AS reported_username,
       r.reason,r.status,r.reported_at,r.resolved_at,r.resolved_by_user_id
FROM spam_reports r JOIN users u ON u.user_id=r.reported_user_id
WHERE ($1 IS NULL OR r.reported_user_id=$1) AND ($2 IS NULL OR r.status=$2)
  AND r.reported_at>=($3::timestamp AT TIME ZONE 'Asia/Ho_Chi_Minh')
  AND r.reported_at<(($4+1)::timestamp AT TIME ZONE 'Asia/Ho_Chi_Minh')
ORDER BY r.reported_at DESC,r.report_id DESC;

-- Q08 UserApp people search: D18 is asymmetric. 2 blocks 3.
-- EXECUTE q_find_users(3,'Trang',50); -> none; (2,'Binh',50) -> user 3.
PREPARE q_find_users(bigint,text,integer) AS
SELECT u.user_id,u.username,u.full_name
FROM users u JOIN users viewer ON viewer.user_id=$1 AND viewer.account_status='ACTIVE' AND viewer.deleted_at IS NULL
WHERE u.user_id<>$1 AND u.account_status='ACTIVE' AND u.deleted_at IS NULL
  AND coalesce($2,'')<>'' AND (strpos(lower(u.username),lower($2))>0 OR strpos(lower(u.full_name),lower($2))>0)
  AND NOT EXISTS(SELECT 1 FROM user_blocks b WHERE b.blocker_id=u.user_id AND b.blocked_id=$1)
ORDER BY u.user_id LIMIT LEAST(GREATEST(coalesce($3,50),1),50);

-- Q09 admin/group metadata: conversation, include closed periods, optional role.
-- These rows do not grant caller permissions; server checks group/system role.
-- EXECUTE q_group_periods(201,false,'ADMIN'); -> period 101.
-- EXECUTE q_group_periods(201,true,NULL); -> periods 101,102,103,104.
PREPARE q_group_periods(bigint,boolean,text) AS
SELECT p.period_id,p.conversation_id,p.user_id,u.username,p.group_role,p.joined_at,p.left_at,
       c.closed_at,u.account_status,u.deleted_at
FROM membership_periods p JOIN conversations c USING(conversation_id) JOIN users u USING(user_id)
WHERE p.conversation_id=$1 AND c.conversation_type='GROUP'
  AND ($2 OR (p.left_at IS NULL AND c.closed_at IS NULL)) AND ($3 IS NULL OR p.group_role=$3)
ORDER BY p.period_id;
