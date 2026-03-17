-- Seed data for local/dev environments.

DO $$
DECLARE
    user_data jsonb;
    user_list jsonb[] := ARRAY[
        '{"id": "13a4a922-06b6-46fd-b0f0-3242b7c988c3", "email": "fleeser@coderave.dev", "password": "password", "name": "Florian Leeser"}',
        '{"id": "0b60e86f-c6b2-4a73-985e-444f0d819ee0", "email": "sroepges@coderave.dev", "password": "password", "name": "Stefan Röpges"}',
        '{"id": "7bdde54f-d770-419b-a33b-5af8164a0f72", "email": "asiegmund@coderave.dev", "password": "password", "name": "Angelique Siegmund"}',
        '{"id": "e4aa5ef3-7cfc-43bd-92d7-7637920b2b78", "email": "dgross@coderave.dev", "password": "password", "name": "Damian Groß"}',
        '{"id": "ff8475f1-5e6c-403d-a092-f7535761e4ad", "email": "gsalanitro@coderave.dev", "password": "password", "name": "Giuseppe Salanitro"}',
        '{"id": "29e656ca-8ca5-4a86-96f3-e50f51d7f975", "email": "sschneider@coderave.dev", "password": "password", "name": "Sebastian Schneider"}'
    ];
BEGIN
    FOREACH user_data IN ARRAY user_list
    LOOP
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
        VALUES (
            '00000000-0000-0000-0000-000000000000',
            (user_data->>'id')::UUID,
            'authenticated',
            'authenticated',
            user_data->>'email',
            crypt(user_data->>'password', gen_salt('bf')),
            current_timestamp,
            current_timestamp,
            current_timestamp,
            '{"provider":"email","providers":["email"]}'::jsonb,
            jsonb_build_object(
                'initial_data', jsonb_build_object(
                    'name', user_data->>'name'
                )
            ),
            current_timestamp,
            current_timestamp,
            '',
            '',
            '',
            ''
        );

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
            uuid_generate_v4(),
            id,
            id,
            format('{"sub":"%s","email":"%s"}', id::text, email)::jsonb,
            'email',
            current_timestamp,
            current_timestamp,
            current_timestamp
        FROM auth.users
        WHERE email = user_data->>'email';
    END LOOP;
END $$;

-- Extended social graph seed data for local/dev environments.
ALTER TABLE public.notifications
DISABLE TRIGGER dbwebhook_notifications_insert_send_push;

DO $$
DECLARE
    florian_id CONSTANT uuid := '13a4a922-06b6-46fd-b0f0-3242b7c988c3';
    stefan_id CONSTANT uuid := '0b60e86f-c6b2-4a73-985e-444f0d819ee0';
    angelique_id CONSTANT uuid := '7bdde54f-d770-419b-a33b-5af8164a0f72';
    damian_id CONSTANT uuid := 'e4aa5ef3-7cfc-43bd-92d7-7637920b2b78';
    giuseppe_id CONSTANT uuid := 'ff8475f1-5e6c-403d-a092-f7535761e4ad';
    sebastian_id CONSTANT uuid := '29e656ca-8ca5-4a86-96f3-e50f51d7f975';
    seeded_at CONSTANT timestamptz := timezone('utc', now());
BEGIN
    INSERT INTO public.friendships (
        user_id,
        friend_id,
        created_at,
        updated_at
    )
    VALUES
        (florian_id, stefan_id, seeded_at - interval '29 days 20 hours', seeded_at - interval '29 days 20 hours'),
        (stefan_id, florian_id, seeded_at - interval '29 days 20 hours', seeded_at - interval '29 days 20 hours'),
        (florian_id, angelique_id, seeded_at - interval '27 days 12 hours', seeded_at - interval '27 days 12 hours'),
        (angelique_id, florian_id, seeded_at - interval '27 days 12 hours', seeded_at - interval '27 days 12 hours'),
        (florian_id, damian_id, seeded_at - interval '25 days 18 hours', seeded_at - interval '25 days 18 hours'),
        (damian_id, florian_id, seeded_at - interval '25 days 18 hours', seeded_at - interval '25 days 18 hours'),
        (florian_id, giuseppe_id, seeded_at - interval '23 days 10 hours', seeded_at - interval '23 days 10 hours'),
        (giuseppe_id, florian_id, seeded_at - interval '23 days 10 hours', seeded_at - interval '23 days 10 hours'),
        (florian_id, sebastian_id, seeded_at - interval '21 days 22 hours', seeded_at - interval '21 days 22 hours'),
        (sebastian_id, florian_id, seeded_at - interval '21 days 22 hours', seeded_at - interval '21 days 22 hours'),
        (stefan_id, angelique_id, seeded_at - interval '19 days 16 hours', seeded_at - interval '19 days 16 hours'),
        (angelique_id, stefan_id, seeded_at - interval '19 days 16 hours', seeded_at - interval '19 days 16 hours'),
        (damian_id, giuseppe_id, seeded_at - interval '17 days 14 hours', seeded_at - interval '17 days 14 hours'),
        (giuseppe_id, damian_id, seeded_at - interval '17 days 14 hours', seeded_at - interval '17 days 14 hours');

    INSERT INTO public.friendship_requests (
        id,
        requester_id,
        addressee_id,
        status,
        created_at,
        updated_at
    )
    VALUES
        ('b1111111-1111-4111-8111-111111111111', florian_id, stefan_id, 'accepted', seeded_at - interval '30 days', seeded_at - interval '29 days 20 hours'),
        ('b2222222-2222-4222-8222-222222222222', angelique_id, florian_id, 'accepted', seeded_at - interval '28 days', seeded_at - interval '27 days 12 hours'),
        ('b3333333-3333-4333-8333-333333333333', florian_id, damian_id, 'accepted', seeded_at - interval '26 days', seeded_at - interval '25 days 18 hours'),
        ('b4444444-4444-4444-8444-444444444444', giuseppe_id, florian_id, 'accepted', seeded_at - interval '24 days', seeded_at - interval '23 days 10 hours'),
        ('b5555555-5555-4555-8555-555555555555', florian_id, sebastian_id, 'accepted', seeded_at - interval '22 days', seeded_at - interval '21 days 22 hours'),
        ('b6666666-6666-4666-8666-666666666666', stefan_id, angelique_id, 'accepted', seeded_at - interval '20 days', seeded_at - interval '19 days 16 hours'),
        ('b7777777-7777-4777-8777-777777777777', damian_id, giuseppe_id, 'accepted', seeded_at - interval '18 days', seeded_at - interval '17 days 14 hours'),
        ('b8888888-8888-4888-8888-888888888888', stefan_id, damian_id, 'pending', seeded_at - interval '7 days', seeded_at - interval '7 days'),
        ('b9999999-9999-4999-8999-999999999999', angelique_id, sebastian_id, 'pending', seeded_at - interval '6 days 12 hours', seeded_at - interval '6 days 12 hours'),
        ('baaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', sebastian_id, giuseppe_id, 'pending', seeded_at - interval '2 days 6 hours', seeded_at - interval '2 days 6 hours'),
        ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', giuseppe_id, stefan_id, 'declined', seeded_at - interval '5 days', seeded_at - interval '4 days 18 hours'),
        ('bccccccc-cccc-4ccc-8ccc-cccccccccccc', angelique_id, damian_id, 'canceled', seeded_at - interval '4 days', seeded_at - interval '3 days 18 hours');

    INSERT INTO public.groups (
        id,
        name,
        created_at,
        updated_at
    )
    VALUES
        ('a1111111-1111-4111-8111-111111111111', 'Solo Workspace', seeded_at - interval '16 days', seeded_at - interval '16 days'),
        ('a2222222-2222-4222-8222-222222222222', 'Coffee Pair', seeded_at - interval '15 days', seeded_at - interval '15 days'),
        ('a3333333-3333-4333-8333-333333333333', 'Launch Trio', seeded_at - interval '14 days', seeded_at - interval '14 days'),
        ('a4444444-4444-4444-8444-444444444444', 'All Hands Crew', seeded_at - interval '13 days', seeded_at - interval '13 days'),
        ('a5555555-5555-4555-8555-555555555555', 'Meme Review Board', seeded_at - interval '12 days', seeded_at - interval '12 days'),
        ('a6666666-6666-4666-8666-666666666666', 'Product Sync', seeded_at - interval '11 days', seeded_at - interval '11 days');

    INSERT INTO public.group_users (
        group_id,
        user_id,
        type,
        created_at,
        updated_at
    )
    VALUES
        ('a1111111-1111-4111-8111-111111111111', florian_id, 'creator', seeded_at - interval '16 days', seeded_at - interval '16 days'),
        ('a2222222-2222-4222-8222-222222222222', florian_id, 'creator', seeded_at - interval '15 days', seeded_at - interval '15 days'),
        ('a2222222-2222-4222-8222-222222222222', stefan_id, 'member', seeded_at - interval '14 days 20 hours', seeded_at - interval '14 days 20 hours'),
        ('a3333333-3333-4333-8333-333333333333', stefan_id, 'creator', seeded_at - interval '14 days', seeded_at - interval '14 days'),
        ('a3333333-3333-4333-8333-333333333333', florian_id, 'admin', seeded_at - interval '13 days 18 hours', seeded_at - interval '13 days 18 hours'),
        ('a3333333-3333-4333-8333-333333333333', angelique_id, 'member', seeded_at - interval '13 days 12 hours', seeded_at - interval '13 days 12 hours'),
        ('a4444444-4444-4444-8444-444444444444', sebastian_id, 'creator', seeded_at - interval '13 days', seeded_at - interval '13 days'),
        ('a4444444-4444-4444-8444-444444444444', florian_id, 'admin', seeded_at - interval '12 days 22 hours', seeded_at - interval '12 days 22 hours'),
        ('a4444444-4444-4444-8444-444444444444', stefan_id, 'member', seeded_at - interval '12 days 20 hours', seeded_at - interval '12 days 20 hours'),
        ('a4444444-4444-4444-8444-444444444444', angelique_id, 'member', seeded_at - interval '12 days 18 hours', seeded_at - interval '12 days 18 hours'),
        ('a4444444-4444-4444-8444-444444444444', damian_id, 'member', seeded_at - interval '12 days 16 hours', seeded_at - interval '12 days 16 hours'),
        ('a4444444-4444-4444-8444-444444444444', giuseppe_id, 'member', seeded_at - interval '12 days 14 hours', seeded_at - interval '12 days 14 hours'),
        ('a5555555-5555-4555-8555-555555555555', damian_id, 'creator', seeded_at - interval '12 days', seeded_at - interval '12 days'),
        ('a5555555-5555-4555-8555-555555555555', giuseppe_id, 'admin', seeded_at - interval '11 days 20 hours', seeded_at - interval '11 days 20 hours'),
        ('a5555555-5555-4555-8555-555555555555', sebastian_id, 'member', seeded_at - interval '11 days 18 hours', seeded_at - interval '11 days 18 hours'),
        ('a6666666-6666-4666-8666-666666666666', angelique_id, 'creator', seeded_at - interval '11 days', seeded_at - interval '11 days'),
        ('a6666666-6666-4666-8666-666666666666', florian_id, 'member', seeded_at - interval '10 days 22 hours', seeded_at - interval '10 days 22 hours'),
        ('a6666666-6666-4666-8666-666666666666', giuseppe_id, 'member', seeded_at - interval '10 days 20 hours', seeded_at - interval '10 days 20 hours'),
        ('a6666666-6666-4666-8666-666666666666', sebastian_id, 'member', seeded_at - interval '10 days 18 hours', seeded_at - interval '10 days 18 hours');

    INSERT INTO public.group_invitations (
        id,
        group_id,
        inviter_id,
        invitee_id,
        status,
        created_at,
        updated_at
    )
    VALUES
        ('c1111111-1111-4111-8111-111111111111', 'a3333333-3333-4333-8333-333333333333', stefan_id, florian_id, 'accepted', seeded_at - interval '13 days 22 hours', seeded_at - interval '13 days 18 hours'),
        ('c2222222-2222-4222-8222-222222222222', 'a2222222-2222-4222-8222-222222222222', florian_id, angelique_id, 'pending', seeded_at - interval '2 days', seeded_at - interval '2 days'),
        ('c3333333-3333-4333-8333-333333333333', 'a3333333-3333-4333-8333-333333333333', stefan_id, giuseppe_id, 'rejected', seeded_at - interval '9 days', seeded_at - interval '8 days 20 hours'),
        ('c4444444-4444-4444-8444-444444444444', 'a6666666-6666-4666-8666-666666666666', angelique_id, damian_id, 'canceled', seeded_at - interval '3 days', seeded_at - interval '2 days 20 hours');
END $$;

ALTER TABLE public.notifications
ENABLE TRIGGER dbwebhook_notifications_insert_send_push;
