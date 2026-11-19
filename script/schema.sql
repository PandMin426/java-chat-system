-- JAVA CHAT SYSTEM / database-schema / PostgreSQL target 17.11.
-- Approved fresh-database DDL. This is not a migration or a repeatable upgrade.
-- Source review only in this session: database execution has NOT RUN.
-- See docs/database/design-baseline.md for F01-F33, U01-U06 and I01-I36.
-- Instants use timestamptz; application report boundaries use Asia/Ho_Chi_Minh.
-- Application transactions own current authorization, lock ordering, immutable
-- history, exactly two PRIVATE member rows, group cardinality/admin transfer,
-- block cleanup, epoch activation and no historical key grants to new devices.
-- Existing seed.sql / tests/verify.sql still target the old schema: do not use
-- them to validate this DDL until they are rewritten for this model.
BEGIN;

-- Stage 1: retained account identity. BCrypt is computed by the application.
CREATE TABLE users (
    user_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
    username text COLLATE "C" NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    full_name text NOT NULL,
    address text DEFAULT NULL,
    birth_date date DEFAULT NULL,
    gender text DEFAULT NULL,
    system_role text NOT NULL DEFAULT 'USER',
    account_status text NOT NULL DEFAULT 'ACTIVE',
    registration_source text NOT NULL,
    must_change_password boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamptz DEFAULT NULL,
    CONSTRAINT users_pkey PRIMARY KEY (user_id),
    CONSTRAINT users_username_format_check
        CHECK (username ~ '^[A-Za-z0-9_]{3,30}$'),
    CONSTRAINT users_email_nonblank_check CHECK (btrim(email) <> ''),
    CONSTRAINT users_email_trimmed_check CHECK (email = btrim(email)),
    CONSTRAINT users_password_hash_nonblank_check CHECK (btrim(password_hash) <> ''),
    CONSTRAINT users_full_name_nonblank_check CHECK (btrim(full_name) <> ''),
    CONSTRAINT users_system_role_check CHECK (system_role IN ('USER', 'ADMIN')),
    CONSTRAINT users_account_status_check CHECK (account_status IN ('ACTIVE', 'LOCKED')),
    CONSTRAINT users_registration_source_check
        CHECK (registration_source IN ('SELF_REGISTERED', 'INTERNAL')),
    CONSTRAINT users_admin_source_check
        CHECK (system_role <> 'ADMIN' OR registration_source = 'INTERNAL'),
    CONSTRAINT users_deleted_at_check CHECK (deleted_at IS NULL OR deleted_at >= created_at)
);

-- Stage 2: objects depending only on users.
-- UserApp successes only. Snapshot authenticity and exactly-once recording are
-- application responsibilities; AdminApp login events belong in admin_audit_log.
CREATE TABLE login_history (
    login_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
    user_id bigint NOT NULL,
    logged_in_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    username_snapshot text NOT NULL,
    full_name_snapshot text NOT NULL,
    remote_ip inet DEFAULT NULL,
    CONSTRAINT login_history_pkey PRIMARY KEY (login_id),
    CONSTRAINT login_history_username_snapshot_check CHECK (btrim(username_snapshot) <> ''),
    CONSTRAINT login_history_full_name_snapshot_check CHECK (btrim(full_name_snapshot) <> ''),
    -- F01
    CONSTRAINT login_history_user_fk FOREIGN KEY (user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

CREATE TABLE friend_requests (
    request_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
    sender_id bigint NOT NULL,
    recipient_id bigint NOT NULL,
    status text NOT NULL DEFAULT 'PENDING',
    requested_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at timestamptz DEFAULT NULL,
    CONSTRAINT friend_requests_pkey PRIMARY KEY (request_id),
    CONSTRAINT friend_requests_distinct_users_check CHECK (sender_id <> recipient_id),
    CONSTRAINT friend_requests_status_check
        CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'CANCELLED')),
    CONSTRAINT friend_requests_resolution_check CHECK (
        (status = 'PENDING' AND resolved_at IS NULL)
        OR (status <> 'PENDING' AND resolved_at IS NOT NULL AND resolved_at >= requested_at)
    ),
    -- F02
    CONSTRAINT friend_requests_sender_fk FOREIGN KEY (sender_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F03
    CONSTRAINT friend_requests_recipient_fk FOREIGN KEY (recipient_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

CREATE TABLE friendships (
    user_low_id bigint NOT NULL,
    user_high_id bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT friendships_pkey PRIMARY KEY (user_low_id, user_high_id),
    CONSTRAINT friendships_ordered_pair_check CHECK (user_low_id < user_high_id),
    -- F04
    CONSTRAINT friendships_low_user_fk FOREIGN KEY (user_low_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F05
    CONSTRAINT friendships_high_user_fk FOREIGN KEY (user_high_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

CREATE TABLE user_blocks (
    blocker_id bigint NOT NULL,
    blocked_id bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_blocks_pkey PRIMARY KEY (blocker_id, blocked_id),
    CONSTRAINT user_blocks_distinct_users_check CHECK (blocker_id <> blocked_id),
    -- F06
    CONSTRAINT user_blocks_blocker_fk FOREIGN KEY (blocker_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F07
    CONSTRAINT user_blocks_blocked_fk FOREIGN KEY (blocked_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

-- The canonical PRIVATE pair is stored here (S1). Child membership cardinality
-- and endpoint immutability must be checked by the authenticated application.
CREATE TABLE conversations (
    conversation_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
    conversation_type text NOT NULL,
    created_by_user_id bigint NOT NULL,
    private_user_low_id bigint DEFAULT NULL,
    private_user_high_id bigint DEFAULT NULL,
    group_name text DEFAULT NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at timestamptz DEFAULT NULL,
    CONSTRAINT conversations_pkey PRIMARY KEY (conversation_id),
    -- U01: discriminator-scoped FK target, not a duplicate plain index.
    CONSTRAINT conversations_id_type_key UNIQUE (conversation_id, conversation_type),
    CONSTRAINT conversations_type_check CHECK (conversation_type IN ('PRIVATE', 'GROUP')),
    CONSTRAINT conversations_shape_check CHECK (
        (
            conversation_type = 'PRIVATE'
            AND private_user_low_id IS NOT NULL AND private_user_high_id IS NOT NULL
            AND private_user_low_id < private_user_high_id
            AND group_name IS NULL AND closed_at IS NULL
            AND created_by_user_id IN (private_user_low_id, private_user_high_id)
        ) OR (
            conversation_type = 'GROUP'
            AND private_user_low_id IS NULL AND private_user_high_id IS NULL
            AND group_name IS NOT NULL AND btrim(group_name) <> ''
            AND (closed_at IS NULL OR closed_at >= created_at)
        )
    ),
    -- F08
    CONSTRAINT conversations_creator_fk FOREIGN KEY (created_by_user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F09: NULL only for GROUP under the shape CHECK.
    CONSTRAINT conversations_private_low_user_fk FOREIGN KEY (private_user_low_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F10
    CONSTRAINT conversations_private_high_user_fk FOREIGN KEY (private_user_high_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

-- Each row is one authorization generation, not a persistent online session.
-- A revoked installation can later receive a new generation; same still-current
-- installation login reuses its generation and preserves locally held keys.
CREATE TABLE e2ee_devices (
    device_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
    user_id bigint NOT NULL,
    device_uid uuid NOT NULL,
    public_key bytea NOT NULL,
    key_format_version smallint NOT NULL DEFAULT 1,
    authorized_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at timestamptz DEFAULT NULL,
    CONSTRAINT e2ee_devices_pkey PRIMARY KEY (device_id),
    -- U03
    CONSTRAINT e2ee_devices_id_user_key UNIQUE (device_id, user_id),
    CONSTRAINT e2ee_devices_public_key_check CHECK (octet_length(public_key) > 0),
    CONSTRAINT e2ee_devices_key_format_version_check CHECK (key_format_version > 0),
    CONSTRAINT e2ee_devices_revoked_at_check
        CHECK (revoked_at IS NULL OR revoked_at >= authorized_at),
    -- F15
    CONSTRAINT e2ee_devices_user_fk FOREIGN KEY (user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

-- Stage 3: one stable row per user/conversation, retained after departure.
-- F24/F25 are added after messages exists; pointers start NULL on first join.
CREATE TABLE conversation_members (
    conversation_id bigint NOT NULL,
    user_id bigint NOT NULL,
    member_created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_read_message_id bigint DEFAULT NULL,
    cleared_at timestamptz DEFAULT NULL,
    cleared_through_message_id bigint DEFAULT NULL,
    CONSTRAINT conversation_members_pkey PRIMARY KEY (conversation_id, user_id),
    CONSTRAINT conversation_members_clear_state_check
        CHECK (cleared_at IS NOT NULL OR cleared_through_message_id IS NULL),
    -- F11
    CONSTRAINT conversation_members_conversation_fk FOREIGN KEY (conversation_id)
        REFERENCES conversations (conversation_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F12
    CONSTRAINT conversation_members_user_fk FOREIGN KEY (user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

-- Stage 4: role/participation history and GROUP-only key cutovers.
CREATE TABLE membership_periods (
    period_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
    conversation_id bigint NOT NULL,
    user_id bigint NOT NULL,
    conversation_type text NOT NULL,
    group_role text NOT NULL DEFAULT 'MEMBER',
    joined_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    left_at timestamptz DEFAULT NULL,
    CONSTRAINT membership_periods_pkey PRIMARY KEY (period_id),
    -- U02: one target binds conversation, user and exact join interval.
    CONSTRAINT membership_periods_conversation_user_period_key
        UNIQUE (conversation_id, user_id, period_id),
    CONSTRAINT membership_periods_type_check CHECK (conversation_type IN ('PRIVATE', 'GROUP')),
    CONSTRAINT membership_periods_role_check CHECK (group_role IN ('MEMBER', 'ADMIN')),
    CONSTRAINT membership_periods_private_role_check
        CHECK (conversation_type <> 'PRIVATE' OR group_role = 'MEMBER'),
    CONSTRAINT membership_periods_left_at_check CHECK (left_at IS NULL OR left_at >= joined_at),
    -- F13
    CONSTRAINT membership_periods_member_fk FOREIGN KEY (conversation_id, user_id)
        REFERENCES conversation_members (conversation_id, user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F14
    CONSTRAINT membership_periods_conversation_type_fk
        FOREIGN KEY (conversation_id, conversation_type)
        REFERENCES conversations (conversation_id, conversation_type) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

-- R1=B: row-local state consistency only. The application blocks sends while
-- PENDING and atomically activates a complete client-generated grant batch.
CREATE TABLE group_key_epochs (
    key_epoch_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
    conversation_id bigint NOT NULL,
    conversation_type text NOT NULL DEFAULT 'GROUP',
    epoch_status text NOT NULL DEFAULT 'PENDING',
    starts_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activated_at timestamptz DEFAULT NULL,
    ends_at timestamptz DEFAULT NULL,
    CONSTRAINT group_key_epochs_pkey PRIMARY KEY (key_epoch_id),
    -- U04
    CONSTRAINT group_key_epochs_conversation_epoch_key UNIQUE (conversation_id, key_epoch_id),
    CONSTRAINT group_key_epochs_group_type_check CHECK (conversation_type = 'GROUP'),
    CONSTRAINT group_key_epochs_status_check CHECK (epoch_status IN ('PENDING', 'ACTIVE', 'CLOSED')),
    CONSTRAINT group_key_epochs_activated_at_check
        CHECK (activated_at IS NULL OR activated_at >= starts_at),
    CONSTRAINT group_key_epochs_ends_at_check CHECK (ends_at IS NULL OR ends_at >= starts_at),
    CONSTRAINT group_key_epochs_activation_end_check
        CHECK (activated_at IS NULL OR ends_at IS NULL OR ends_at >= activated_at),
    CONSTRAINT group_key_epochs_state_check CHECK (
        (epoch_status = 'PENDING' AND activated_at IS NULL AND ends_at IS NULL)
        OR (epoch_status = 'ACTIVE' AND activated_at IS NOT NULL AND ends_at IS NULL)
        OR (epoch_status = 'CLOSED' AND ends_at IS NOT NULL)
    ),
    -- F16: a PRIVATE conversation cannot acquire a GROUP epoch.
    CONSTRAINT group_key_epochs_conversation_type_fk
        FOREIGN KEY (conversation_id, conversation_type)
        REFERENCES conversations (conversation_id, conversation_type) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

-- Stage 5: opaque wrapped keys only (R2=A). These FKs prove group/period/owner
-- correspondence, not open-state eligibility or cryptographic correctness.
CREATE TABLE group_key_grants (
    key_epoch_id bigint NOT NULL,
    device_id bigint NOT NULL,
    conversation_id bigint NOT NULL,
    user_id bigint NOT NULL,
    period_id bigint NOT NULL,
    wrapped_key bytea NOT NULL,
    envelope_version smallint NOT NULL DEFAULT 1,
    granted_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT group_key_grants_pkey PRIMARY KEY (key_epoch_id, device_id),
    -- U05: messages must use the grant belonging to the exact sending period.
    CONSTRAINT group_key_grants_epoch_device_period_key
        UNIQUE (key_epoch_id, device_id, period_id),
    CONSTRAINT group_key_grants_wrapped_key_check CHECK (octet_length(wrapped_key) > 0),
    CONSTRAINT group_key_grants_envelope_version_check CHECK (envelope_version > 0),
    -- F17
    CONSTRAINT group_key_grants_epoch_fk FOREIGN KEY (conversation_id, key_epoch_id)
        REFERENCES group_key_epochs (conversation_id, key_epoch_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F18: shared conversation_id and user_id bind the recipient interval.
    CONSTRAINT group_key_grants_period_fk FOREIGN KEY (conversation_id, user_id, period_id)
        REFERENCES membership_periods (conversation_id, user_id, period_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F19: the same user must own that device.
    CONSTRAINT group_key_grants_device_owner_fk FOREIGN KEY (device_id, user_id)
        REFERENCES e2ee_devices (device_id, user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

-- Stage 6: shared retained text events. The application checks live state and
-- acquires the conversation lock before allocating/inserting a message ID.
CREATE TABLE messages (
    message_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
    conversation_id bigint NOT NULL,
    conversation_type text NOT NULL,
    sender_user_id bigint NOT NULL,
    sender_period_id bigint NOT NULL,
    sent_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    text_content text DEFAULT NULL,
    ciphertext bytea DEFAULT NULL,
    payload_version smallint DEFAULT NULL,
    key_epoch_id bigint DEFAULT NULL,
    sender_device_id bigint DEFAULT NULL,
    CONSTRAINT messages_pkey PRIMARY KEY (message_id),
    -- U06: also serves reverse message-ID history scans; no duplicate index.
    CONSTRAINT messages_conversation_message_key UNIQUE (conversation_id, message_id),
    CONSTRAINT messages_type_check CHECK (conversation_type IN ('PRIVATE', 'GROUP')),
    CONSTRAINT messages_payload_shape_check CHECK (
        (
            conversation_type = 'PRIVATE'
            AND text_content IS NOT NULL AND length(text_content) > 0
            AND ciphertext IS NULL AND payload_version IS NULL
            AND key_epoch_id IS NULL AND sender_device_id IS NULL
        ) OR (
            conversation_type = 'GROUP'
            AND text_content IS NULL
            AND ciphertext IS NOT NULL AND octet_length(ciphertext) > 0
            AND payload_version IS NOT NULL AND payload_version > 0
            AND key_epoch_id IS NOT NULL AND sender_device_id IS NOT NULL
        )
    ),
    -- F20
    CONSTRAINT messages_conversation_type_fk FOREIGN KEY (conversation_id, conversation_type)
        REFERENCES conversations (conversation_id, conversation_type) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F21: current membership is an application check; this proves exact scope.
    CONSTRAINT messages_sender_period_fk
        FOREIGN KEY (conversation_id, sender_user_id, sender_period_id)
        REFERENCES membership_periods (conversation_id, user_id, period_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F22: NULL bypass is intentional only for PRIVATE, enforced by payload CHECK.
    CONSTRAINT messages_epoch_fk FOREIGN KEY (conversation_id, key_epoch_id)
        REFERENCES group_key_epochs (conversation_id, key_epoch_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F23: GROUP requires all three components; the grant owner is bound by F18/F19.
    CONSTRAINT messages_sender_grant_period_fk
        FOREIGN KEY (key_epoch_id, sender_device_id, sender_period_id)
        REFERENCES group_key_grants (key_epoch_id, device_id, period_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

-- Stage 7: solve the member -> message -> period -> member cycle in DDL order.
-- F24/F25: NULL pointers intentionally skip MATCH SIMPLE; non-NULL IDs cannot
-- point into another conversation. Monotonicity/history eligibility is in app.
ALTER TABLE conversation_members
    ADD CONSTRAINT conversation_members_read_message_fk
        FOREIGN KEY (conversation_id, last_read_message_id)
        REFERENCES messages (conversation_id, message_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    ADD CONSTRAINT conversation_members_clear_message_fk
        FOREIGN KEY (conversation_id, cleared_through_message_id)
        REFERENCES messages (conversation_id, message_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE;

CREATE TABLE message_hidden (
    message_id bigint NOT NULL,
    user_id bigint NOT NULL,
    conversation_id bigint NOT NULL,
    hidden_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT message_hidden_pkey PRIMARY KEY (message_id, user_id),
    -- F26
    CONSTRAINT message_hidden_message_fk FOREIGN KEY (conversation_id, message_id)
        REFERENCES messages (conversation_id, message_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F27: the hide owner and hidden message share this conversation_id.
    CONSTRAINT message_hidden_member_fk FOREIGN KEY (conversation_id, user_id)
        REFERENCES conversation_members (conversation_id, user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

-- Incoming PRIVATE evidence, D38 transitions and handler ADMIN role are checked
-- by the application transaction, not by a cross-table CHECK or trigger.
CREATE TABLE spam_reports (
    report_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
    reporter_id bigint NOT NULL,
    reported_user_id bigint NOT NULL,
    reason text DEFAULT NULL,
    status text NOT NULL DEFAULT 'PENDING',
    reported_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at timestamptz DEFAULT NULL,
    resolved_by_user_id bigint DEFAULT NULL,
    CONSTRAINT spam_reports_pkey PRIMARY KEY (report_id),
    CONSTRAINT spam_reports_distinct_users_check CHECK (reporter_id <> reported_user_id),
    CONSTRAINT spam_reports_reason_check CHECK (reason IS NULL OR btrim(reason) <> ''),
    CONSTRAINT spam_reports_status_check CHECK (status IN ('PENDING', 'RESOLVED', 'DISMISSED')),
    CONSTRAINT spam_reports_resolution_check CHECK (
        (status = 'PENDING' AND resolved_at IS NULL AND resolved_by_user_id IS NULL)
        OR (
            status <> 'PENDING'
            AND resolved_at IS NOT NULL AND resolved_by_user_id IS NOT NULL
            AND resolved_at >= reported_at
        )
    ),
    -- F28
    CONSTRAINT spam_reports_reporter_fk FOREIGN KEY (reporter_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F29
    CONSTRAINT spam_reports_reported_user_fk FOREIGN KEY (reported_user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F30
    CONSTRAINT spam_reports_handler_fk FOREIGN KEY (resolved_by_user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

-- Stage 8: administration events. Multiple rows share operation_id to preserve
-- request/failure/manual-retry/ACK history. No outbox or automatic worker (Q2=A).
CREATE TABLE admin_audit_log (
    audit_id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
    actor_user_id bigint NOT NULL,
    actor_username_snapshot text NOT NULL,
    actor_full_name_snapshot text NOT NULL,
    operation_id uuid NOT NULL,
    event_type text NOT NULL,
    outcome text NOT NULL,
    target_user_id bigint DEFAULT NULL,
    target_report_id bigint DEFAULT NULL,
    event_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    detail text DEFAULT NULL,
    CONSTRAINT admin_audit_log_pkey PRIMARY KEY (audit_id),
    CONSTRAINT admin_audit_log_actor_username_check CHECK (btrim(actor_username_snapshot) <> ''),
    CONSTRAINT admin_audit_log_actor_full_name_check CHECK (btrim(actor_full_name_snapshot) <> ''),
    CONSTRAINT admin_audit_log_event_type_check CHECK (event_type IN (
        'LOGIN_SUCCESS', 'USER_CREATED', 'USER_UPDATED', 'PASSWORD_RESET',
        'USER_LOCKED', 'USER_UNLOCKED', 'USER_SOFT_DELETED',
        'SPAM_DISMISSED', 'SPAM_RESOLVED', 'CONTROL_REQUESTED',
        'CONTROL_ACKNOWLEDGED', 'CONTROL_FAILED', 'CONTROL_UNKNOWN'
    )),
    CONSTRAINT admin_audit_log_outcome_check CHECK (outcome IN ('PENDING', 'SUCCESS', 'FAILED', 'UNKNOWN')),
    CONSTRAINT admin_audit_log_control_target_check CHECK (
        event_type NOT IN ('CONTROL_REQUESTED', 'CONTROL_ACKNOWLEDGED', 'CONTROL_FAILED', 'CONTROL_UNKNOWN')
        OR target_user_id IS NOT NULL
    ),
    -- F31
    CONSTRAINT admin_audit_log_actor_fk FOREIGN KEY (actor_user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F32
    CONSTRAINT admin_audit_log_target_user_fk FOREIGN KEY (target_user_id)
        REFERENCES users (user_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE,
    -- F33
    CONSTRAINT admin_audit_log_target_report_fk FOREIGN KEY (target_report_id)
        REFERENCES spam_reports (report_id) MATCH SIMPLE
        ON DELETE RESTRICT ON UPDATE RESTRICT NOT DEFERRABLE
);

-- Explicit indexes I01-I36. Wider U01-U06 keys exist for composite FKs;
-- do not create additional plain indexes for their existing access prefixes.
-- I01/I02: deleted_at is deliberately absent from the uniqueness predicates.
CREATE UNIQUE INDEX users_username_ci_uidx ON users (lower(username COLLATE "C"));
CREATE UNIQUE INDEX users_email_ci_uidx ON users (lower(email));
-- I03/I04
CREATE INDEX users_created_idx ON users (created_at, user_id);
CREATE INDEX users_full_name_idx ON users (lower(full_name), user_id);
-- I05/I06
CREATE INDEX login_history_user_time_idx
    ON login_history (user_id, logged_in_at DESC, login_id DESC);
CREATE INDEX login_history_time_idx
    ON login_history (logged_in_at DESC, login_id DESC) INCLUDE (user_id);
-- I07: reciprocal invitation acceptance is still an application transaction.
CREATE UNIQUE INDEX friend_requests_pending_pair_uidx
    ON friend_requests ((LEAST(sender_id, recipient_id)), (GREATEST(sender_id, recipient_id)))
    WHERE status = 'PENDING';
-- I08/I09
CREATE INDEX friend_requests_inbox_idx
    ON friend_requests (recipient_id, status, requested_at DESC, request_id DESC);
CREATE INDEX friend_requests_outbox_idx
    ON friend_requests (sender_id, status, requested_at DESC, request_id DESC);
-- I10/I11
CREATE INDEX friendships_high_user_idx ON friendships (user_high_id, user_low_id);
CREATE INDEX user_blocks_blocked_user_idx ON user_blocks (blocked_id, blocker_id);
-- I12/I13
CREATE UNIQUE INDEX conversations_private_pair_uidx
    ON conversations (private_user_low_id, private_user_high_id) WHERE conversation_type = 'PRIVATE';
CREATE INDEX conversations_private_high_user_idx
    ON conversations (private_user_high_id, private_user_low_id) WHERE conversation_type = 'PRIVATE';
-- I14/I15/I16
CREATE INDEX conversations_group_name_idx
    ON conversations (lower(group_name), conversation_id) WHERE conversation_type = 'GROUP';
CREATE INDEX conversations_group_created_idx
    ON conversations (created_at, conversation_id) WHERE conversation_type = 'GROUP';
CREATE INDEX conversations_creator_idx ON conversations (created_by_user_id, conversation_id);
-- I17/I18/I19
CREATE INDEX conversation_members_user_idx ON conversation_members (user_id, conversation_id);
CREATE UNIQUE INDEX membership_periods_open_member_uidx
    ON membership_periods (conversation_id, user_id) WHERE left_at IS NULL;
CREATE INDEX membership_periods_open_role_idx
    ON membership_periods (conversation_id, group_role, user_id) WHERE left_at IS NULL;
-- I20/I21
CREATE UNIQUE INDEX e2ee_devices_current_user_uidx ON e2ee_devices (user_id) WHERE revoked_at IS NULL;
CREATE INDEX e2ee_devices_installation_idx
    ON e2ee_devices (user_id, device_uid, authorized_at DESC, device_id);
-- I22/I23
CREATE UNIQUE INDEX group_key_epochs_unended_uidx ON group_key_epochs (conversation_id) WHERE ends_at IS NULL;
CREATE INDEX group_key_epochs_timeline_idx ON group_key_epochs (conversation_id, starts_at, key_epoch_id);
-- I24/I25
CREATE INDEX group_key_grants_device_idx ON group_key_grants (device_id, key_epoch_id);
CREATE INDEX group_key_grants_period_idx
    ON group_key_grants (conversation_id, user_id, period_id, key_epoch_id);
-- I26/I27: U06 already supports conversation history ordered by message_id.
CREATE INDEX messages_sender_time_idx
    ON messages (sender_user_id, sent_at, conversation_type, conversation_id);
CREATE INDEX messages_sender_period_idx ON messages (sender_period_id, message_id);
-- I28/I29/I30/I31
CREATE UNIQUE INDEX spam_reports_pending_pair_uidx
    ON spam_reports (reporter_id, reported_user_id) WHERE status = 'PENDING';
CREATE INDEX spam_reports_target_status_time_idx
    ON spam_reports (reported_user_id, status, reported_at DESC, report_id DESC);
CREATE INDEX spam_reports_time_idx ON spam_reports (reported_at DESC, report_id DESC);
CREATE INDEX spam_reports_reporter_time_idx
    ON spam_reports (reporter_id, reported_at DESC, report_id DESC);
-- I32
CREATE INDEX message_hidden_member_idx ON message_hidden (conversation_id, user_id, message_id);
-- I33/I34/I35/I36
CREATE INDEX admin_audit_log_time_idx ON admin_audit_log (event_at DESC, audit_id DESC);
CREATE INDEX admin_audit_log_operation_idx ON admin_audit_log (operation_id, audit_id);
CREATE INDEX admin_audit_log_actor_time_idx
    ON admin_audit_log (actor_user_id, event_at DESC, audit_id DESC);
CREATE INDEX admin_audit_log_target_time_idx
    ON admin_audit_log (target_user_id, event_at DESC, audit_id DESC) WHERE target_user_id IS NOT NULL;

COMMIT;
