-- Seed data for local/dev environments.

DO $$
DECLARE
    user_data jsonb;
    v_florian_id uuid := 'a3bb189e-7c1d-4b2e-9f6b-1234567890ab';
    v_stefan_id uuid := 'a3bb189e-7c1d-4b2e-9f6b-1234567890ac';
    v_request_id uuid := 'a3bb189e-7c1d-4b2e-9f6b-1234567890ad';
    user_list jsonb[] := ARRAY[
        '{"id": "a3bb189e-7c1d-4b2e-9f6b-1234567890ab", "email": "fleeser@coderave.dev", "password": "password", "name": "Florian Leeser"}',
        '{"id": "a3bb189e-7c1d-4b2e-9f6b-1234567890ac", "email": "sroepges@coderave.dev", "password": "password", "name": "Stefan Röpges"}',
        '{"id": "22977b2d-d84f-4a0d-8f8b-3e6d3a6a4d3c", "email": "ssiegmund@coderave.dev", "password": "password", "name": "Angelique Siegmund"}'
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
