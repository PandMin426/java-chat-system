-- Java Chat System - Database V1 (PostgreSQL 17.11).
-- Run on a fresh database. Application timestamps are stored as instants;
-- use Asia/Ho_Chi_Minh for report boundaries and display.
BEGIN;

CREATE TABLE users (
    user_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username text COLLATE "C",
    email text,
    password_hash text,
    full_name text,
    address text,
    birth_date date,
    gender text,
    system_role text NOT NULL DEFAULT 'USER',
    account_status text NOT NULL DEFAULT 'ACTIVE',
    registration_source text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_system_role_check CHECK (system_role IN ('ADMIN', 'USER')),
    CONSTRAINT users_account_status_check CHECK (account_status IN ('ACTIVE', 'LOCKED', 'DELETED')),
    CONSTRAINT users_registration_source_check CHECK (registration_source IN ('SELF_REGISTERED', 'INTERNAL')),
    CONSTRAINT users_admin_source_check CHECK (system_role <> 'ADMIN' OR registration_source = 'INTERNAL'),
    CONSTRAINT users_profile_state_check CHECK (
        (
            account_status <> 'DELETED'
            AND username IS NOT NULL AND btrim(username) <> ''
            AND email IS NOT NULL AND btrim(email) <> ''
            AND password_hash IS NOT NULL AND btrim(password_hash) <> ''
            AND full_name IS NOT NULL AND btrim(full_name) <> ''
        ) OR (
            account_status = 'DELETED'
            AND username IS NULL AND email IS NULL AND password_hash IS NULL
            AND full_name IS NULL AND address IS NULL AND birth_date IS NULL AND gender IS NULL
        )
    )
);

CREATE UNIQUE INDEX users_live_username_uidx
    ON users (username) WHERE account_status <> 'DELETED';

CREATE UNIQUE INDEX users_live_email_uidx
    ON users (lower(email)) WHERE account_status <> 'DELETED';

-- Soft-delete with one UPDATE: set account_status to DELETED and clear all
-- seven profile/credential fields checked by users_profile_state_check.
-- Keep the same user_id, created_at and registration_source for history.
CREATE FUNCTION guard_user_lifecycle() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Use soft delete to preserve the user identity and history'
            USING ERRCODE = 'check_violation';
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF NEW.user_id IS DISTINCT FROM OLD.user_id THEN
            RAISE EXCEPTION 'The user identity cannot be changed'
                USING ERRCODE = 'check_violation';
        END IF;

        IF NEW.created_at IS DISTINCT FROM OLD.created_at
            OR NEW.registration_source IS DISTINCT FROM OLD.registration_source THEN
            RAISE EXCEPTION 'The account creation timestamp and registration source cannot be changed'
                USING ERRCODE = 'check_violation';
        END IF;

        IF OLD.account_status = 'DELETED' AND NEW.account_status IS DISTINCT FROM 'DELETED' THEN
            RAISE EXCEPTION 'A deleted account cannot be reactivated'
                USING ERRCODE = 'check_violation';
        END IF;

        IF NEW.account_status <> 'DELETED' AND NEW.username IS DISTINCT FROM OLD.username THEN
            RAISE EXCEPTION 'The username cannot be changed'
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;

    -- Strip surrounding whitespace before profile checks and the unique index.
    NEW.email := regexp_replace(NEW.email, '^[[:space:]]+|[[:space:]]+$', '', 'g');
    RETURN NEW;
END;
$$;

CREATE TRIGGER users_lifecycle_guard
    BEFORE INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION guard_user_lifecycle();

-- Write only successful authentications. Join users for the current profile.
CREATE TABLE login_events (
    login_event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    logged_in_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX login_events_user_time_idx
    ON login_events (user_id, logged_in_at, login_event_id);

CREATE INDEX login_events_time_idx
    ON login_events (logged_in_at DESC, login_event_id DESC);

-- Write one event per app launch once its user is known, including reused sessions.
CREATE TABLE app_open_events (
    app_open_event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    opened_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX app_open_events_time_user_idx
    ON app_open_events (opened_at, user_id);

-- Prompt 06: Social relationships, private messaging and spam reports.
CREATE TABLE friend_requests (
    friend_request_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sender_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    recipient_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    request_status text NOT NULL DEFAULT 'PENDING',
    requested_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at timestamptz,
    CONSTRAINT friend_requests_distinct_users_check CHECK (sender_id <> recipient_id),
    CONSTRAINT friend_requests_status_check CHECK (request_status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'CANCELLED')),
    CONSTRAINT friend_requests_resolution_check CHECK (
        (request_status = 'PENDING' AND resolved_at IS NULL)
        OR (request_status <> 'PENDING' AND resolved_at IS NOT NULL AND resolved_at >= requested_at)
    )
);

CREATE INDEX friend_requests_inbox_idx
    ON friend_requests (recipient_id, request_status, requested_at DESC, friend_request_id DESC);

CREATE UNIQUE INDEX friend_requests_pending_pair_uidx
    ON friend_requests ((LEAST(sender_id, recipient_id)), (GREATEST(sender_id, recipient_id)))
    WHERE request_status = 'PENDING';

CREATE TABLE friendships (
    user_low_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    user_high_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    PRIMARY KEY (user_low_id, user_high_id),
    CONSTRAINT friendships_ordered_pair_check CHECK (user_low_id < user_high_id)
);

CREATE INDEX friendships_high_user_idx ON friendships (user_high_id, user_low_id);

CREATE TABLE user_blocks (
    blocker_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    blocked_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    PRIMARY KEY (blocker_id, blocked_id),
    CONSTRAINT user_blocks_distinct_users_check CHECK (blocker_id <> blocked_id)
);

CREATE INDEX user_blocks_blocked_user_idx ON user_blocks (blocked_id, blocker_id);

CREATE TABLE private_conversations (
    conversation_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_low_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    user_high_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    CONSTRAINT private_conversations_unique_pair UNIQUE (user_low_id, user_high_id),
    CONSTRAINT private_conversations_ordered_pair_check CHECK (user_low_id < user_high_id)
);

CREATE INDEX private_conversations_high_user_idx ON private_conversations (user_high_id, user_low_id);

CREATE TABLE private_messages (
    private_message_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    conversation_id bigint NOT NULL REFERENCES private_conversations (conversation_id) ON DELETE RESTRICT,
    sender_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    content text NOT NULL,
    sent_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX private_messages_history_idx
    ON private_messages (conversation_id, sent_at DESC, private_message_id DESC);

CREATE INDEX private_messages_sender_time_idx ON private_messages (sender_id, sent_at);

CREATE TABLE private_message_hides (
    private_message_id bigint NOT NULL REFERENCES private_messages (private_message_id) ON DELETE RESTRICT,
    user_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    PRIMARY KEY (private_message_id, user_id)
);

CREATE TABLE spam_reports (
    spam_report_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reporter_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    reported_user_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    reported_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT spam_reports_distinct_users_check CHECK (reporter_id <> reported_user_id)
);

CREATE INDEX spam_reports_time_idx ON spam_reports (reported_at DESC, spam_report_id DESC);

CREATE INDEX spam_reports_reported_user_time_idx
    ON spam_reports (reported_user_id, reported_at DESC, spam_report_id DESC);

-- Serialize block, invitation, friendship and send operations for the same pair.
-- The check after acquiring the lock needs a fresh READ COMMITTED snapshot.
CREATE FUNCTION lock_social_pair(first_user_id bigint, second_user_id bigint) RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF current_setting('transaction_isolation') <> 'read committed' THEN
        RAISE EXCEPTION 'Social pair writes require READ COMMITTED isolation'
            USING ERRCODE = 'feature_not_supported';
    END IF;

    PERFORM pg_advisory_xact_lock(hashtextextended(
        'java-chat:social-pair:' || LEAST(first_user_id, second_user_id)::text
        || ':' || GREATEST(first_user_id, second_user_id)::text, 0
    ));
END;
$$;

CREATE FUNCTION social_pair_is_blocked(first_user_id bigint, second_user_id bigint) RETURNS boolean
LANGUAGE sql VOLATILE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM user_blocks
        WHERE (blocker_id = first_user_id AND blocked_id = second_user_id)
           OR (blocker_id = second_user_id AND blocked_id = first_user_id)
    );
$$;

-- Acceptance is a backend transaction: use READ COMMITTED, lock the pair
-- before writing, then update the recipient's PENDING request to ACCEPTED
-- with resolved_at set. Only if exactly one row changed, insert the ordered
-- friendship in the same transaction. Roll back if the friendship write fails.
CREATE FUNCTION guard_friend_request() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.request_status IS DISTINCT FROM 'PENDING' THEN
            RAISE EXCEPTION 'A new friend request must start as PENDING'
                USING ERRCODE = 'check_violation';
        END IF;
    ELSE
        IF (NEW.sender_id, NEW.recipient_id) IS DISTINCT FROM (OLD.sender_id, OLD.recipient_id) THEN
            RAISE EXCEPTION 'A friend request cannot change its participants'
                USING ERRCODE = 'check_violation';
        END IF;

        IF OLD.request_status <> 'PENDING' AND NEW.request_status IS DISTINCT FROM OLD.request_status THEN
            RAISE EXCEPTION 'A resolved friend request cannot change status'
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;

    IF NEW.request_status IN ('PENDING', 'ACCEPTED') THEN
        PERFORM lock_social_pair(NEW.sender_id, NEW.recipient_id);

        IF NEW.request_status = 'PENDING' AND EXISTS (
            SELECT 1 FROM user_blocks
            WHERE blocker_id = NEW.recipient_id AND blocked_id = NEW.sender_id
        ) THEN
            RAISE EXCEPTION 'The recipient has blocked this friend request sender'
                USING ERRCODE = 'check_violation';
        END IF;

        IF NEW.request_status = 'ACCEPTED' AND social_pair_is_blocked(NEW.sender_id, NEW.recipient_id) THEN
            RAISE EXCEPTION 'A friend request cannot be accepted while either user blocks the other'
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER friend_requests_guard
    BEFORE INSERT OR UPDATE ON friend_requests
    FOR EACH ROW EXECUTE FUNCTION guard_friend_request();

CREATE FUNCTION guard_friendship() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM lock_social_pair(NEW.user_low_id, NEW.user_high_id);
    IF social_pair_is_blocked(NEW.user_low_id, NEW.user_high_id) THEN
        RAISE EXCEPTION 'A friendship cannot be created while either user blocks the other'
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER friendships_guard
    BEFORE INSERT OR UPDATE OF user_low_id, user_high_id ON friendships
    FOR EACH ROW EXECUTE FUNCTION guard_friendship();

CREATE FUNCTION apply_user_block() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        IF (NEW.blocker_id, NEW.blocked_id) IS DISTINCT FROM (OLD.blocker_id, OLD.blocked_id) THEN
            RAISE EXCEPTION 'A block cannot change its participants'
                USING ERRCODE = 'check_violation';
        END IF;
        RETURN NEW;
    END IF;

    PERFORM lock_social_pair(NEW.blocker_id, NEW.blocked_id);

    DELETE FROM friendships
    WHERE user_low_id = LEAST(NEW.blocker_id, NEW.blocked_id)
      AND user_high_id = GREATEST(NEW.blocker_id, NEW.blocked_id);

    UPDATE friend_requests
    SET request_status = 'CANCELLED', resolved_at = GREATEST(clock_timestamp(), requested_at)
    WHERE request_status = 'PENDING'
      AND LEAST(sender_id, recipient_id) = LEAST(NEW.blocker_id, NEW.blocked_id)
      AND GREATEST(sender_id, recipient_id) = GREATEST(NEW.blocker_id, NEW.blocked_id);

    RETURN NEW;
END;
$$;

CREATE TRIGGER user_blocks_apply
    AFTER INSERT OR UPDATE ON user_blocks
    FOR EACH ROW EXECUTE FUNCTION apply_user_block();

CREATE FUNCTION guard_private_conversation_pair() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF (NEW.user_low_id, NEW.user_high_id) IS DISTINCT FROM (OLD.user_low_id, OLD.user_high_id) THEN
        RAISE EXCEPTION 'A private conversation cannot change its participants'
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER private_conversations_pair_guard
    BEFORE UPDATE OF user_low_id, user_high_id ON private_conversations
    FOR EACH ROW EXECUTE FUNCTION guard_private_conversation_pair();

CREATE FUNCTION guard_private_message() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    low_user_id bigint;
    high_user_id bigint;
BEGIN
    IF TG_OP <> 'INSERT' THEN
        RAISE EXCEPTION 'Private messages are retained; use a per-user hide for history deletion'
            USING ERRCODE = 'check_violation';
    END IF;

    SELECT user_low_id, user_high_id INTO low_user_id, high_user_id
    FROM private_conversations
    WHERE conversation_id = NEW.conversation_id;

    IF NOT FOUND THEN
        -- The conversation FK rejects missing references.
        RETURN NEW;
    END IF;

    IF NEW.sender_id NOT IN (low_user_id, high_user_id) THEN
        RAISE EXCEPTION 'The sender must belong to the private conversation'
            USING ERRCODE = 'check_violation';
    END IF;

    PERFORM lock_social_pair(low_user_id, high_user_id);
    IF social_pair_is_blocked(low_user_id, high_user_id) THEN
        RAISE EXCEPTION 'Private messages are blocked between these users'
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER private_messages_guard
    BEFORE INSERT OR UPDATE OR DELETE ON private_messages
    FOR EACH ROW EXECUTE FUNCTION guard_private_message();

CREATE FUNCTION guard_private_message_hide() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    low_user_id bigint;
    high_user_id bigint;
BEGIN
    SELECT c.user_low_id, c.user_high_id INTO low_user_id, high_user_id
    FROM private_messages m
    JOIN private_conversations c ON c.conversation_id = m.conversation_id
    WHERE m.private_message_id = NEW.private_message_id;

    IF FOUND AND NEW.user_id NOT IN (low_user_id, high_user_id) THEN
        RAISE EXCEPTION 'Only a conversation participant can hide its messages'
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER private_message_hides_guard
    BEFORE INSERT OR UPDATE OF private_message_id, user_id ON private_message_hides
    FOR EACH ROW EXECUTE FUNCTION guard_private_message_hide();

CREATE FUNCTION guard_spam_report() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM private_conversations c
        JOIN private_messages m ON m.conversation_id = c.conversation_id
        WHERE c.user_low_id = LEAST(NEW.reporter_id, NEW.reported_user_id)
          AND c.user_high_id = GREATEST(NEW.reporter_id, NEW.reported_user_id)
    ) THEN
        RAISE EXCEPTION 'A spam report requires at least one private message between the users'
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER spam_reports_guard
    BEFORE INSERT OR UPDATE OF reporter_id, reported_user_id ON spam_reports
    FOR EACH ROW EXECUTE FUNCTION guard_spam_report();

-- Prompt 07: Group chat and storage metadata for end-to-end encryption.
CREATE TABLE chat_groups (
    group_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_name text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at timestamptz,
    CONSTRAINT chat_groups_name_check CHECK (btrim(group_name) <> ''),
    CONSTRAINT chat_groups_closed_at_check CHECK (closed_at >= created_at)
);

CREATE INDEX chat_groups_name_idx ON chat_groups (lower(group_name), group_id);
CREATE INDEX chat_groups_created_at_idx ON chat_groups (created_at, group_id);

-- Create the group, creator ADMIN membership, and at least one other MEMBER
-- in one backend transaction. End memberships with left_at; keep closed rows.
CREATE TABLE group_memberships (
    membership_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_id bigint NOT NULL REFERENCES chat_groups (group_id) ON DELETE RESTRICT,
    user_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    group_role text NOT NULL DEFAULT 'MEMBER',
    joined_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    left_at timestamptz,
    CONSTRAINT group_memberships_group_membership_key UNIQUE (group_id, membership_id),
    CONSTRAINT group_memberships_grant_owner_key UNIQUE (group_id, membership_id, user_id),
    CONSTRAINT group_memberships_role_check CHECK (group_role IN ('ADMIN', 'MEMBER')),
    CONSTRAINT group_memberships_left_at_check CHECK (left_at >= joined_at)
);

CREATE UNIQUE INDEX group_memberships_active_pair_uidx
    ON group_memberships (group_id, user_id) WHERE left_at IS NULL;

CREATE INDEX group_memberships_active_user_idx
    ON group_memberships (user_id, group_id) WHERE left_at IS NULL;

CREATE TABLE e2ee_devices (
    device_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES users (user_id) ON DELETE RESTRICT,
    public_key bytea NOT NULL,
    authorized_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at timestamptz,
    CONSTRAINT e2ee_devices_owner_key UNIQUE (device_id, user_id),
    CONSTRAINT e2ee_devices_public_key_check CHECK (octet_length(public_key) > 0),
    CONSTRAINT e2ee_devices_revoked_at_check CHECK (revoked_at >= authorized_at)
);

CREATE UNIQUE INDEX e2ee_devices_active_user_uidx
    ON e2ee_devices (user_id) WHERE revoked_at IS NULL;

CREATE TABLE group_key_epochs (
    key_epoch_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_id bigint NOT NULL REFERENCES chat_groups (group_id) ON DELETE RESTRICT,
    starts_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ends_at timestamptz,
    CONSTRAINT group_key_epochs_group_epoch_key UNIQUE (group_id, key_epoch_id),
    CONSTRAINT group_key_epochs_ends_at_check CHECK (ends_at >= starts_at)
);

CREATE UNIQUE INDEX group_key_epochs_open_group_uidx
    ON group_key_epochs (group_id) WHERE ends_at IS NULL;

-- The shared user_id binds the membership to a device owned by that user.
-- Only the wrapped key is stored here.
CREATE TABLE group_key_grants (
    key_epoch_id bigint NOT NULL,
    device_id bigint NOT NULL,
    group_id bigint NOT NULL,
    membership_id bigint NOT NULL,
    user_id bigint NOT NULL,
    wrapped_key bytea NOT NULL,
    PRIMARY KEY (key_epoch_id, device_id),
    CONSTRAINT group_key_grants_epoch_fk FOREIGN KEY (group_id, key_epoch_id)
        REFERENCES group_key_epochs (group_id, key_epoch_id) ON DELETE RESTRICT,
    CONSTRAINT group_key_grants_membership_fk FOREIGN KEY (group_id, membership_id, user_id)
        REFERENCES group_memberships (group_id, membership_id, user_id) ON DELETE RESTRICT,
    CONSTRAINT group_key_grants_device_fk FOREIGN KEY (device_id, user_id)
        REFERENCES e2ee_devices (device_id, user_id) ON DELETE RESTRICT,
    CONSTRAINT group_key_grants_wrapped_key_check CHECK (octet_length(wrapped_key) > 0)
);

CREATE INDEX group_key_grants_device_idx ON group_key_grants (device_id, key_epoch_id);

-- New grants must start with an open epoch, membership and device. An epoch
-- cannot expose messages from before the member joined or device was authorized.
CREATE FUNCTION guard_group_key_grant() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1 FROM chat_groups
    WHERE group_id = NEW.group_id AND closed_at IS NULL
    FOR SHARE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'A new key grant requires an open group'
            USING ERRCODE = 'check_violation';
    END IF;

    PERFORM 1
    FROM group_key_epochs e
    JOIN group_memberships m ON m.group_id = e.group_id
    JOIN e2ee_devices d ON d.device_id = NEW.device_id
    WHERE e.group_id = NEW.group_id AND e.key_epoch_id = NEW.key_epoch_id
      AND m.membership_id = NEW.membership_id
      AND e.ends_at IS NULL AND m.left_at IS NULL AND d.revoked_at IS NULL
      AND e.starts_at >= GREATEST(m.joined_at, d.authorized_at)
    FOR SHARE OF e, m, d;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'A key grant requires an open epoch within the membership and device authorization'
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER group_key_grants_guard
    BEFORE INSERT OR UPDATE ON group_key_grants
    FOR EACH ROW EXECUTE FUNCTION guard_group_key_grant();

CREATE TABLE group_messages (
    group_message_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_id bigint NOT NULL,
    key_epoch_id bigint NOT NULL,
    sender_membership_id bigint NOT NULL,
    encrypted_payload bytea NOT NULL,
    sent_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT group_messages_epoch_fk FOREIGN KEY (group_id, key_epoch_id)
        REFERENCES group_key_epochs (group_id, key_epoch_id) ON DELETE RESTRICT,
    CONSTRAINT group_messages_sender_fk FOREIGN KEY (group_id, sender_membership_id)
        REFERENCES group_memberships (group_id, membership_id) ON DELETE RESTRICT,
    CONSTRAINT group_messages_payload_check CHECK (octet_length(encrypted_payload) > 0)
);

CREATE INDEX group_messages_history_idx
    ON group_messages (group_id, sent_at DESC, group_message_id DESC);

CREATE INDEX group_messages_sender_time_idx ON group_messages (sender_membership_id, sent_at);

-- Membership/epoch transitions in the backend lock the group row first.
-- Shared locks keep the checked state stable until the send commits.
CREATE FUNCTION guard_group_message() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    sender_joined_at timestamptz;
BEGIN
    PERFORM 1 FROM chat_groups
    WHERE group_id = NEW.group_id AND closed_at IS NULL
    FOR SHARE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'A group message requires an open group'
            USING ERRCODE = 'check_violation';
    END IF;

    SELECT joined_at INTO sender_joined_at FROM group_memberships
    WHERE group_id = NEW.group_id AND membership_id = NEW.sender_membership_id
      AND left_at IS NULL AND joined_at <= NEW.sent_at
    FOR SHARE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'The sender must be an active member of this group'
            USING ERRCODE = 'check_violation';
    END IF;

    PERFORM 1 FROM group_key_epochs
    WHERE group_id = NEW.group_id AND key_epoch_id = NEW.key_epoch_id
      AND ends_at IS NULL AND starts_at BETWEEN sender_joined_at AND NEW.sent_at
    FOR SHARE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'A group message requires the current key epoch of this group'
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER group_messages_guard
    BEFORE INSERT OR UPDATE OF group_id, sender_membership_id, key_epoch_id, sent_at ON group_messages
    FOR EACH ROW EXECUTE FUNCTION guard_group_message();

COMMIT;
