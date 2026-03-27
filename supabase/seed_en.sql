-- Rich social seed data for App Store screenshots.
-- Locale: en
-- All users use password: password

CREATE OR REPLACE FUNCTION pg_temp.seed_uuid(p_seed text)
RETURNS uuid
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT (
    substr(md5(p_seed), 1, 8) || '-' ||
    substr(md5(p_seed), 9, 4) || '-' ||
    '4' || substr(md5(p_seed), 14, 3) || '-' ||
    'a' || substr(md5(p_seed), 18, 3) || '-' ||
    substr(md5(p_seed), 21, 12)
  )::uuid;
$$;

DO $$
DECLARE
  v_seed_key CONSTANT text := 'en';
  v_user_count CONSTANT integer := 36;
  v_seeded_at CONSTANT timestamptz := timezone('utc', now());
  v_first_names text[] := ARRAY['Amelia','Oliver','Isla','George','Freya','Arthur','Ivy','Leo','Poppy','Henry','Elsie','Oscar','Rosie','Theo','Matilda','Jack','Evie','Hugo'];
  v_last_names text[] := ARRAY['Taylor','Wilson','Clarke','Hughes','Edwards','Jenkins','Baker','Palmer','Davies','Mason','Grant','Fletcher','Chapman','Shaw','Spencer','Cole','Barker','Hunter','Sinclair','Morgan'];

  v_pos integer;
  v_name text;
  v_email text;
BEGIN
  DROP TABLE IF EXISTS tmp_seed_users;
  CREATE TEMP TABLE tmp_seed_users (
    pos integer PRIMARY KEY,
    id uuid NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    created_at timestamptz NOT NULL
  ) ON COMMIT DROP;

  FOR v_pos IN 1..v_user_count LOOP
    v_name :=
      v_first_names[((v_pos - 1) % array_length(v_first_names, 1)) + 1] ||
      ' ' ||
      v_last_names[((v_pos * 7 - 1) % array_length(v_last_names, 1)) + 1];

    v_email :=
      lower(left(regexp_replace(split_part(v_name, ' ', 1), '[^a-zA-Z0-9]+', '', 'g'), 1)) ||
      lower(regexp_replace(split_part(v_name, ' ', 2), '[^a-zA-Z0-9]+', '', 'g')) ||
      '@coderave.dev';

    INSERT INTO tmp_seed_users (pos, id, name, email, created_at)
    VALUES (
      v_pos,
      pg_temp.seed_uuid(format('%s:user:%s', v_seed_key, v_pos)),
      v_name,
      v_email,
      v_seeded_at - make_interval(days => (160 - v_pos))
    );
  END LOOP;

  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  )
  SELECT
    '00000000-0000-0000-0000-000000000000'::uuid,
    u.id,
    'authenticated',
    'authenticated',
    u.email,
    crypt('password', gen_salt('bf')),
    u.created_at,
    u.created_at,
    u.created_at,
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object(
      'initial_data',
      jsonb_build_object('name', u.name)
    ),
    u.created_at,
    u.created_at,
    '',
    '',
    '',
    ''
  FROM tmp_seed_users u
  ON CONFLICT DO NOTHING;

  INSERT INTO auth.identities (
    id,
    user_id,
    provider_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  )
  SELECT
    pg_temp.seed_uuid(format('%s:identity:%s', v_seed_key, u.pos)),
    u.id,
    u.id,
    jsonb_build_object('sub', u.id::text, 'email', u.email),
    'email',
    u.created_at,
    u.created_at,
    u.created_at
  FROM tmp_seed_users u
  ON CONFLICT DO NOTHING;
END;
$$;

ALTER TABLE public.notifications
DISABLE TRIGGER dbwebhook_notifications_insert_send_push;

DO $$
DECLARE
  v_seed_key CONSTANT text := 'en';
  v_user_count CONSTANT integer := 36;
  v_groups_per_user CONSTANT integer := 4;
  v_group_count CONSTANT integer := v_user_count * v_groups_per_user;
  v_invites_per_group CONSTANT integer := 12;
  v_seeded_at CONSTANT timestamptz := timezone('utc', now());

  v_group_prefixes text[] := ARRAY['TeaBreak','RainyDay','Commute','Retro','Sketch','Sprint','Book','Photo','Weekend','Studio','Launch','Cozy'];
  v_group_suffixes text[] := ARRAY['Circle','Society','Guild','Collective','Group','Corner','Network','Room','Crew','Table','Forum','Hub'];
BEGIN
  DROP TABLE IF EXISTS tmp_seed_users;
  CREATE TEMP TABLE tmp_seed_users (
    pos integer PRIMARY KEY,
    id uuid NOT NULL
  ) ON COMMIT DROP;

  INSERT INTO tmp_seed_users (pos, id)
  SELECT
    i,
    pg_temp.seed_uuid(format('%s:user:%s', v_seed_key, i))
  FROM generate_series(1, v_user_count) AS i;

  DROP TABLE IF EXISTS tmp_friendship_requests;
  CREATE TEMP TABLE tmp_friendship_requests (
    id uuid PRIMARY KEY,
    requester_id uuid NOT NULL,
    addressee_id uuid NOT NULL,
    target_status public.friendship_request_status NOT NULL,
    created_at timestamptz NOT NULL
  ) ON COMMIT DROP;

  INSERT INTO tmp_friendship_requests (
    id,
    requester_id,
    addressee_id,
    target_status,
    created_at
  )
  SELECT
    pg_temp.seed_uuid(format('%s:friendship-request:%s:%s', v_seed_key, a.pos, b.pos)),
    CASE
      WHEN mod(a.pos * 11 + b.pos * 7, 2) = 0 THEN a.id
      ELSE b.id
    END AS requester_id,
    CASE
      WHEN mod(a.pos * 11 + b.pos * 7, 2) = 0 THEN b.id
      ELSE a.id
    END AS addressee_id,
    CASE
      WHEN mod(a.pos * 37 + b.pos * 17, 100) < 58 THEN 'accepted'::public.friendship_request_status
      WHEN mod(a.pos * 37 + b.pos * 17, 100) < 88 THEN 'pending'::public.friendship_request_status
      WHEN mod(a.pos * 37 + b.pos * 17, 100) < 95 THEN 'declined'::public.friendship_request_status
      ELSE 'canceled'::public.friendship_request_status
    END AS target_status,
    v_seeded_at - make_interval(days => 95) + make_interval(hours => (a.pos * 5 + b.pos * 3))
  FROM tmp_seed_users a
  JOIN tmp_seed_users b ON a.pos < b.pos;

  INSERT INTO public.friendship_requests (
    id,
    requester_id,
    addressee_id,
    status,
    created_at,
    updated_at
  )
  SELECT
    fr.id,
    fr.requester_id,
    fr.addressee_id,
    'pending'::public.friendship_request_status,
    fr.created_at,
    fr.created_at
  FROM tmp_friendship_requests fr
  ON CONFLICT (id) DO NOTHING;

  UPDATE public.friendship_requests fr
  SET status = s.target_status
  FROM tmp_friendship_requests s
  WHERE fr.id = s.id
    AND s.target_status <> 'pending'::public.friendship_request_status
    AND fr.status = 'pending'::public.friendship_request_status;

  DROP TABLE IF EXISTS tmp_groups;
  CREATE TEMP TABLE tmp_groups (
    pos integer PRIMARY KEY,
    id uuid NOT NULL,
    creator_pos integer NOT NULL,
    creator_id uuid NOT NULL,
    name text NOT NULL,
    created_at timestamptz NOT NULL
  ) ON COMMIT DROP;

  INSERT INTO tmp_groups (
    pos,
    id,
    creator_pos,
    creator_id,
    name,
    created_at
  )
  SELECT
    g_pos,
    pg_temp.seed_uuid(format('%s:group:%s', v_seed_key, g_pos)),
    ((g_pos - 1) % v_user_count) + 1,
    u.id,
    v_group_prefixes[((g_pos - 1) % array_length(v_group_prefixes, 1)) + 1] ||
      ' ' ||
      v_group_suffixes[((g_pos * 5 - 1) % array_length(v_group_suffixes, 1)) + 1] AS name,
    v_seeded_at - make_interval(days => 70) + make_interval(hours => (g_pos * 2)) AS created_at
  FROM generate_series(1, v_group_count) AS g_pos
  JOIN tmp_seed_users u ON u.pos = ((g_pos - 1) % v_user_count) + 1;

  INSERT INTO public.groups (
    id,
    name,
    created_at,
    updated_at
  )
  SELECT
    g.id,
    g.name,
    g.created_at,
    g.created_at
  FROM tmp_groups g
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.group_users (
    group_id,
    user_id,
    type,
    created_at,
    updated_at
  )
  SELECT
    g.id,
    g.creator_id,
    'creator'::public.group_user_type,
    g.created_at,
    g.created_at
  FROM tmp_groups g
  ON CONFLICT (group_id, user_id) DO NOTHING;

  DROP TABLE IF EXISTS tmp_group_invitations;
  CREATE TEMP TABLE tmp_group_invitations (
    id uuid PRIMARY KEY,
    group_id uuid NOT NULL,
    inviter_id uuid NOT NULL,
    invitee_id uuid NOT NULL,
    target_status public.group_invitation_status NOT NULL,
    created_at timestamptz NOT NULL
  ) ON COMMIT DROP;

  INSERT INTO tmp_group_invitations (
    id,
    group_id,
    inviter_id,
    invitee_id,
    target_status,
    created_at
  )
  SELECT
    pg_temp.seed_uuid(format('%s:group-invitation:%s:%s', v_seed_key, g.pos, invitee.pos)),
    g.id,
    g.creator_id,
    invitee.id,
    CASE
      WHEN mod(g.pos * 13 + invitee.pos * 5 + off, 100) < 55 THEN 'accepted'::public.group_invitation_status
      WHEN mod(g.pos * 13 + invitee.pos * 5 + off, 100) < 78 THEN 'pending'::public.group_invitation_status
      WHEN mod(g.pos * 13 + invitee.pos * 5 + off, 100) < 90 THEN 'rejected'::public.group_invitation_status
      ELSE 'canceled'::public.group_invitation_status
    END AS target_status,
    g.created_at + make_interval(hours => (off * 4) + mod(g.pos, 3)) AS created_at
  FROM tmp_groups g
  CROSS JOIN generate_series(1, v_invites_per_group) AS off
  JOIN tmp_seed_users invitee
    ON invitee.pos = ((g.creator_pos + off + mod(g.pos, 5) - 1) % v_user_count) + 1;

  INSERT INTO public.group_invitations (
    id,
    group_id,
    inviter_id,
    invitee_id,
    status,
    created_at,
    updated_at
  )
  SELECT
    gi.id,
    gi.group_id,
    gi.inviter_id,
    gi.invitee_id,
    'pending'::public.group_invitation_status,
    gi.created_at,
    gi.created_at
  FROM tmp_group_invitations gi
  ON CONFLICT (id) DO NOTHING;

  UPDATE public.group_invitations gi
  SET status = s.target_status
  FROM tmp_group_invitations s
  WHERE gi.id = s.id
    AND s.target_status <> 'pending'::public.group_invitation_status
    AND gi.status = 'pending'::public.group_invitation_status;

  UPDATE public.friendships f
  SET created_at =
    v_seeded_at - make_interval(days => 8 + mod(abs(hashtext(f.user_id::text || f.friend_id::text)::bigint), 36)::integer) +
    make_interval(hours => mod(abs(hashtext(f.friend_id::text)::bigint), 24)::integer)
  WHERE f.user_id IN (SELECT id FROM tmp_seed_users)
    AND f.friend_id IN (SELECT id FROM tmp_seed_users);

  UPDATE public.group_users gu
  SET created_at =
    g.created_at + make_interval(hours => mod(abs(hashtext(gu.user_id::text || gu.group_id::text)::bigint), 96)::integer)
  FROM public.groups g
  WHERE gu.group_id = g.id
    AND g.id IN (SELECT id FROM tmp_groups)
    AND gu.user_id IN (SELECT id FROM tmp_seed_users);

  UPDATE public.notifications n
  SET
    is_read = mod(abs(hashtext(n.id::text || n.recipient_id::text)::bigint), 100)::integer < 68,
    created_at =
      v_seeded_at - make_interval(days => 1 + mod(abs(hashtext(n.id::text)::bigint), 35)::integer) -
      make_interval(hours => mod(abs(hashtext(n.recipient_id::text)::bigint), 24)::integer)
  WHERE n.recipient_id IN (SELECT id FROM tmp_seed_users)
    AND n.type IN (
      'friendship_request_sent'::public.notification_type,
      'friendship_request_accepted'::public.notification_type,
      'group_invitation_sent'::public.notification_type
    );
END;
$$;

ALTER TABLE public.notifications
ENABLE TRIGGER dbwebhook_notifications_insert_send_push;
