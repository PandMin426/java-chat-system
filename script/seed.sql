-- Demo fixtures for a fresh V1 schema. Run once, on a test database only.
-- Password, public key, wrapped key and ciphertext values are placeholders.
BEGIN;

DO $$
DECLARE
    minh_id bigint;
    lower_minh_id bigint;
    trang_id bigint;
    binh_id bigint;
    archived_id bigint;
    chat_id bigint;
    archived_chat_id bigint;
    hidden_id bigint;
    team_id bigint;
    closed_team_id bigint;
    minh_membership bigint;
    trang_membership bigint;
    archived_membership bigint;
    old_device bigint;
    new_device bigint;
    trang_device bigint;
    epoch_id bigint;
    first_at CONSTANT timestamptz := '2026-10-31 16:00:00+00';
    change_at CONSTANT timestamptz := '2026-10-31 17:00:00+00';
    rejoin_at CONSTANT timestamptz := '2026-10-31 18:00:00+00';
BEGIN
    INSERT INTO users (username, email, password_hash, full_name, registration_source, created_at)
    VALUES ('Minh', ' Minh@example.test ', 'fixture-only', 'Minh Hòa', 'SELF_REGISTERED', first_at)
    RETURNING user_id INTO minh_id;
    INSERT INTO users (username, email, password_hash, full_name, registration_source, created_at)
    VALUES ('minh', 'other@example.test', 'fixture-only', 'Minh Hoa', 'SELF_REGISTERED', change_at)
    RETURNING user_id INTO lower_minh_id;
    INSERT INTO users (username, email, password_hash, full_name, registration_source, created_at)
    VALUES ('Trang', 'trang@example.test', 'fixture-only', 'Thu Trang', 'SELF_REGISTERED', first_at)
    RETURNING user_id INTO trang_id;
    INSERT INTO users (username, email, password_hash, full_name, registration_source, created_at)
    VALUES ('Binh', 'binh@example.test', 'fixture-only', 'Bình An', 'SELF_REGISTERED', change_at)
    RETURNING user_id INTO binh_id;
    INSERT INTO users (username, email, password_hash, full_name, registration_source, created_at)
    VALUES ('archive', 'archive@example.test', 'fixture-only', 'Archive', 'SELF_REGISTERED', first_at)
    RETURNING user_id INTO archived_id;
    INSERT INTO users (username, email, password_hash, full_name, system_role, account_status, registration_source, created_at)
    VALUES ('demo_admin', 'admin@example.test', 'fixture-only', 'Demo Admin', 'ADMIN', 'ACTIVE', 'INTERNAL', change_at),
           ('locked_user', 'locked@example.test', 'fixture-only', 'Locked User', 'USER', 'LOCKED', 'INTERNAL', change_at);

    INSERT INTO login_events (user_id, logged_in_at)
    VALUES (minh_id, first_at), (minh_id, change_at), (archived_id, first_at);
    INSERT INTO app_open_events (user_id, opened_at)
    VALUES (minh_id, first_at), (minh_id, change_at), (minh_id, rejoin_at), (trang_id, rejoin_at);

    PERFORM lock_social_pair(minh_id, trang_id);
    PERFORM lock_social_pair(trang_id, binh_id);
    INSERT INTO friend_requests (sender_id, recipient_id, requested_at)
    VALUES (minh_id, trang_id, first_at), (trang_id, binh_id, first_at),
           (lower_minh_id, binh_id, first_at), (minh_id, binh_id, first_at);
    UPDATE friend_requests SET request_status = 'ACCEPTED', resolved_at = change_at
    WHERE (sender_id, recipient_id) IN ((minh_id, trang_id), (trang_id, binh_id));
    INSERT INTO friendships (user_low_id, user_high_id)
    VALUES (LEAST(minh_id, trang_id), GREATEST(minh_id, trang_id)),
           (LEAST(trang_id, binh_id), GREATEST(trang_id, binh_id));
    INSERT INTO user_blocks (blocker_id, blocked_id) VALUES (binh_id, lower_minh_id);

    INSERT INTO private_conversations (user_low_id, user_high_id)
    VALUES (LEAST(minh_id, trang_id), GREATEST(minh_id, trang_id)) RETURNING conversation_id INTO chat_id;
    INSERT INTO private_conversations (user_low_id, user_high_id)
    VALUES (LEAST(minh_id, archived_id), GREATEST(minh_id, archived_id)) RETURNING conversation_id INTO archived_chat_id;
    INSERT INTO private_conversations (user_low_id, user_high_id)
    VALUES (LEAST(minh_id, lower_minh_id), GREATEST(minh_id, lower_minh_id));

    INSERT INTO private_messages (conversation_id, sender_id, content, sent_at)
    VALUES (chat_id, minh_id, 'Hòa nhắn từ bản mẫu', change_at) RETURNING private_message_id INTO hidden_id;
    INSERT INTO private_messages (conversation_id, sender_id, content, sent_at)
    VALUES (chat_id, trang_id, 'Tin vẫn hiện với người nhận', rejoin_at),
           (chat_id, trang_id, 'Hoa không dấu', rejoin_at),
           (archived_chat_id, archived_id, 'Tin nhắn của tài khoản cũ', first_at);
    INSERT INTO private_message_hides (private_message_id, user_id) VALUES (hidden_id, minh_id);
    INSERT INTO spam_reports (reporter_id, reported_user_id, reported_at)
    VALUES (minh_id, trang_id, rejoin_at), (minh_id, trang_id, rejoin_at), (minh_id, archived_id, change_at);

    INSERT INTO chat_groups (group_name, created_at) VALUES ('Nhóm V1', first_at) RETURNING group_id INTO team_id;
    INSERT INTO group_memberships (group_id, user_id, group_role, joined_at)
    VALUES (team_id, minh_id, 'ADMIN', first_at) RETURNING membership_id INTO minh_membership;
    INSERT INTO group_memberships (group_id, user_id, joined_at)
    VALUES (team_id, trang_id, first_at) RETURNING membership_id INTO trang_membership;
    INSERT INTO e2ee_devices (user_id, public_key, authorized_at)
    VALUES (minh_id, decode('0101', 'hex'), first_at) RETURNING device_id INTO old_device;
    INSERT INTO e2ee_devices (user_id, public_key, authorized_at)
    VALUES (trang_id, decode('0201', 'hex'), first_at) RETURNING device_id INTO trang_device;
    INSERT INTO group_key_epochs (group_id, starts_at) VALUES (team_id, first_at) RETURNING key_epoch_id INTO epoch_id;
    INSERT INTO group_key_grants (key_epoch_id, device_id, group_id, membership_id, user_id, wrapped_key)
    VALUES (epoch_id, old_device, team_id, minh_membership, minh_id, decode('1101', 'hex')),
           (epoch_id, trang_device, team_id, trang_membership, trang_id, decode('1201', 'hex'));
    INSERT INTO group_messages (group_id, key_epoch_id, sender_membership_id, encrypted_payload, sent_at)
    VALUES (team_id, epoch_id, minh_membership, decode('2101', 'hex'), first_at + interval '30 minutes');

    UPDATE group_memberships SET left_at = change_at WHERE membership_id = trang_membership;
    UPDATE e2ee_devices SET revoked_at = change_at WHERE device_id = old_device;
    UPDATE group_key_epochs SET ends_at = change_at WHERE key_epoch_id = epoch_id;
    INSERT INTO e2ee_devices (user_id, public_key, authorized_at)
    VALUES (minh_id, decode('0102', 'hex'), change_at) RETURNING device_id INTO new_device;
    INSERT INTO group_key_epochs (group_id, starts_at) VALUES (team_id, change_at) RETURNING key_epoch_id INTO epoch_id;
    INSERT INTO group_key_grants (key_epoch_id, device_id, group_id, membership_id, user_id, wrapped_key)
    VALUES (epoch_id, new_device, team_id, minh_membership, minh_id, decode('1102', 'hex'));
    INSERT INTO group_messages (group_id, key_epoch_id, sender_membership_id, encrypted_payload, sent_at)
    VALUES (team_id, epoch_id, minh_membership, decode('2102', 'hex'), change_at + interval '15 minutes');

    UPDATE group_key_epochs SET ends_at = rejoin_at WHERE key_epoch_id = epoch_id;
    INSERT INTO group_memberships (group_id, user_id, joined_at)
    VALUES (team_id, trang_id, rejoin_at) RETURNING membership_id INTO trang_membership;
    INSERT INTO group_key_epochs (group_id, starts_at) VALUES (team_id, rejoin_at) RETURNING key_epoch_id INTO epoch_id;
    INSERT INTO group_key_grants (key_epoch_id, device_id, group_id, membership_id, user_id, wrapped_key)
    VALUES (epoch_id, new_device, team_id, minh_membership, minh_id, decode('1103', 'hex')),
           (epoch_id, trang_device, team_id, trang_membership, trang_id, decode('1203', 'hex'));
    INSERT INTO group_messages (group_id, key_epoch_id, sender_membership_id, encrypted_payload, sent_at)
    VALUES (team_id, epoch_id, trang_membership, decode('2103', 'hex'), rejoin_at + interval '5 minutes');

    INSERT INTO chat_groups (group_name, created_at) VALUES ('Nhóm lưu trữ', first_at) RETURNING group_id INTO closed_team_id;
    INSERT INTO group_memberships (group_id, user_id, group_role, joined_at)
    VALUES (closed_team_id, archived_id, 'ADMIN', first_at) RETURNING membership_id INTO archived_membership;
    INSERT INTO group_memberships (group_id, user_id, joined_at) VALUES (closed_team_id, binh_id, first_at);
    UPDATE chat_groups SET closed_at = rejoin_at WHERE group_id = closed_team_id;
    UPDATE group_memberships SET left_at = rejoin_at WHERE membership_id = archived_membership;
    UPDATE users SET account_status = 'DELETED', username = NULL, email = NULL, password_hash = NULL,
        full_name = NULL, address = NULL, birth_date = NULL, gender = NULL WHERE user_id = archived_id;
    INSERT INTO users (username, email, password_hash, full_name, registration_source, created_at)
    VALUES ('archive', ' ARCHIVE@example.test ', 'fixture-only', 'Replacement', 'SELF_REGISTERED', rejoin_at);
END;
$$;

COMMIT;
