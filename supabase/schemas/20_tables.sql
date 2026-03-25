SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."friendship_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "requester_id" "uuid" NOT NULL,
    "addressee_id" "uuid" NOT NULL,
    "pair_low" "uuid" GENERATED ALWAYS AS (LEAST("requester_id", "addressee_id")) STORED,
    "pair_high" "uuid" GENERATED ALWAYS AS (GREATEST("requester_id", "addressee_id")) STORED,
    "status" "public"."friendship_request_status" DEFAULT 'pending'::"public"."friendship_request_status" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "ck_friendship_requests__neq_user_ids" CHECK (("requester_id" <> "addressee_id"))
);




CREATE TABLE IF NOT EXISTS "public"."friendships" (
    "user_id" "uuid" NOT NULL,
    "friend_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "ck_friendships__neq_user_ids" CHECK (("user_id" <> "friend_id"))
);




CREATE TABLE IF NOT EXISTS "public"."group_invitations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "group_id" "uuid" NOT NULL,
    "inviter_id" "uuid" NOT NULL,
    "invitee_id" "uuid" NOT NULL,
    "status" "public"."group_invitation_status" DEFAULT 'pending'::"public"."group_invitation_status" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "ck_group_invitations__neq_user_ids" CHECK (("inviter_id" <> "invitee_id"))
);




CREATE TABLE IF NOT EXISTS "public"."group_users" (
    "group_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "type" "public"."group_user_type" DEFAULT 'member'::"public"."group_user_type" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);




CREATE TABLE IF NOT EXISTS "public"."groups" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "ck_groups__name_length" CHECK ((("length"(TRIM(BOTH FROM "name")) >= 1) AND ("length"(TRIM(BOTH FROM "name")) <= 64)))
);




CREATE TABLE IF NOT EXISTS "public"."meme_laughs" (
    "meme_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);




CREATE TABLE IF NOT EXISTS "public"."meme_recipients" (
    "meme_id" "uuid" NOT NULL,
    "user_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "group_id" "uuid",
    CONSTRAINT "ck_meme_recipients__exactly_one_target" CHECK (("num_nonnulls"("user_id", "group_id") = 1))
);




CREATE TABLE IF NOT EXISTS "public"."meme_templates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "image_path" "text" NOT NULL,
    "image_path_low" "text" NOT NULL,
    "aspect_ratio" double precision NOT NULL,
    "tags" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "tags_search_text" "text" DEFAULT ''::"text" NOT NULL,
    CONSTRAINT "ck_meme_templates__positive_aspect_ratio" CHECK (("aspect_ratio" > (0)::double precision))
);




CREATE TABLE IF NOT EXISTS "public"."memes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "template_id" "uuid" NOT NULL,
    "image_path" "text" NOT NULL,
    "push_image_path" "text",
    "push_preview_status" "public"."push_preview_status" DEFAULT 'pending'::"public"."push_preview_status" NOT NULL,
    "aspect_ratio" double precision NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "ck_memes__image_path_not_empty" CHECK (("length"(TRIM(BOTH FROM "image_path")) > 0)),
    CONSTRAINT "ck_memes__positive_aspect_ratio" CHECK (("aspect_ratio" > (0)::double precision)),
    CONSTRAINT "ck_memes__push_image_path_not_empty" CHECK ((("push_image_path" IS NULL) OR ("length"(TRIM(BOTH FROM "push_image_path")) > 0)))
);




CREATE TABLE IF NOT EXISTS "public"."notification_push_templates" (
    "notification_type" "public"."notification_type" NOT NULL,
    "language_code" "text" NOT NULL,
    "country_code" "text",
    "title" "text",
    "message" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "ck_notification_push_templates__country_code_format" CHECK ((("country_code" IS NULL) OR ("country_code" ~ '^[A-Z]{2}$'::"text"))),
    CONSTRAINT "ck_notification_push_templates__language_code_format" CHECK (("language_code" ~ '^[a-z]{2}$'::"text")),
    CONSTRAINT "ck_notification_push_templates__message_not_empty" CHECK (("length"(TRIM(BOTH FROM "message")) > 0)),
    CONSTRAINT "ck_notification_push_templates__title_not_empty" CHECK ((("title" IS NULL) OR ("length"(TRIM(BOTH FROM "title")) > 0)))
);




CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "recipient_id" "uuid" NOT NULL,
    "type" "public"."notification_type" NOT NULL,
    "data" "jsonb" NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "ck_notifications__data_shape" CHECK (
CASE "type"
    WHEN 'friendship_request_sent'::"public"."notification_type" THEN (("jsonb_typeof"("data") = 'object'::"text") AND ("jsonb_typeof"(("data" -> 'actor_id'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'actor_name'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'actor_friendship_code'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'request_id'::"text")) = 'string'::"text") AND (("data" ->> 'actor_friendship_code'::"text") ~ '^[0-9]{8}$'::"text") AND ("data" ? 'route_tab'::"text") AND (("data" ->> 'route_tab'::"text") = 'requests'::"text"))
    WHEN 'friendship_request_accepted'::"public"."notification_type" THEN (("jsonb_typeof"("data") = 'object'::"text") AND ("jsonb_typeof"(("data" -> 'actor_id'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'actor_name'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'actor_friendship_code'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'request_id'::"text")) = 'string'::"text") AND (("data" ->> 'actor_friendship_code'::"text") ~ '^[0-9]{8}$'::"text") AND ("data" ? 'route_tab'::"text") AND (("data" ->> 'route_tab'::"text") = 'friendships'::"text"))
    WHEN 'group_invitation_sent'::"public"."notification_type" THEN (("jsonb_typeof"("data") = 'object'::"text") AND ("jsonb_typeof"(("data" -> 'actor_id'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'actor_name'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'actor_friendship_code'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'invitation_id'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'group_id'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'group_name'::"text")) = 'string'::"text") AND (("data" ->> 'actor_friendship_code'::"text") ~ '^[0-9]{8}$'::"text") AND ("length"(TRIM(BOTH FROM ("data" ->> 'group_name'::"text"))) > 0) AND ("data" ? 'route_tab'::"text") AND (("data" ->> 'route_tab'::"text") = 'invitations'::"text"))
    WHEN 'meme_received'::"public"."notification_type" THEN (("jsonb_typeof"("data") = 'object'::"text") AND ("jsonb_typeof"(("data" -> 'actor_id'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'actor_name'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'meme_id'::"text")) = 'string'::"text") AND ("data" ? 'push_image_path'::"text") AND ((("data" -> 'push_image_path'::"text") = 'null'::"jsonb") OR (("jsonb_typeof"(("data" -> 'push_image_path'::"text")) = 'string'::"text") AND ("length"(TRIM(BOTH FROM ("data" ->> 'push_image_path'::"text"))) > 0))) AND ("jsonb_typeof"(("data" -> 'aspect_ratio'::"text")) = 'number'::"text") AND ((("data" ->> 'aspect_ratio'::"text"))::double precision > (0)::double precision) AND ("data" ? 'route_tab'::"text") AND (("data" -> 'route_tab'::"text") = 'null'::"jsonb") AND ((NOT ("data" ? 'group_id'::"text")) OR (("data" -> 'group_id'::"text") = 'null'::"jsonb") OR ("jsonb_typeof"(("data" -> 'group_id'::"text")) = 'string'::"text")) AND ((NOT ("data" ? 'group_name'::"text")) OR (("data" -> 'group_name'::"text") = 'null'::"jsonb") OR (("jsonb_typeof"(("data" -> 'group_name'::"text")) = 'string'::"text") AND ("length"(TRIM(BOTH FROM ("data" ->> 'group_name'::"text"))) > 0))))
    WHEN 'meme_laughed'::"public"."notification_type" THEN (("jsonb_typeof"("data") = 'object'::"text") AND ("jsonb_typeof"(("data" -> 'actor_id'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'actor_name'::"text")) = 'string'::"text") AND ("jsonb_typeof"(("data" -> 'meme_id'::"text")) = 'string'::"text") AND ("data" ? 'push_image_path'::"text") AND ((("data" -> 'push_image_path'::"text") = 'null'::"jsonb") OR (("jsonb_typeof"(("data" -> 'push_image_path'::"text")) = 'string'::"text") AND ("length"(TRIM(BOTH FROM ("data" ->> 'push_image_path'::"text"))) > 0))) AND ("jsonb_typeof"(("data" -> 'aspect_ratio'::"text")) = 'number'::"text") AND ((("data" ->> 'aspect_ratio'::"text"))::double precision > (0)::double precision) AND ("data" ? 'route_tab'::"text") AND (("data" -> 'route_tab'::"text") = 'null'::"jsonb"))
    ELSE false
END)
);




CREATE TABLE IF NOT EXISTS "public"."push_device_tokens" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "installation_id" "text" NOT NULL,
    "fcm_token" "text" NOT NULL,
    "platform" "public"."push_platform" NOT NULL,
    "language_code" "text" NOT NULL,
    "country_code" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "deactivation_reason" "public"."push_token_deactivation_reason",
    "deactivated_at" timestamp with time zone,
    "last_seen_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "ck_push_device_tokens__country_code_format" CHECK ((("country_code" IS NULL) OR ("country_code" ~ '^[A-Z]{2}$'::"text"))),
    CONSTRAINT "ck_push_device_tokens__deactivation_consistency" CHECK (((("is_active" = true) AND ("deactivation_reason" IS NULL) AND ("deactivated_at" IS NULL)) OR (("is_active" = false) AND ("deactivation_reason" IS NOT NULL) AND ("deactivated_at" IS NOT NULL)))),
    CONSTRAINT "ck_push_device_tokens__fcm_token_not_empty" CHECK (("length"(TRIM(BOTH FROM "fcm_token")) > 0)),
    CONSTRAINT "ck_push_device_tokens__installation_id_not_empty" CHECK (("length"(TRIM(BOTH FROM "installation_id")) > 0)),
    CONSTRAINT "ck_push_device_tokens__language_code_format" CHECK (("language_code" ~ '^[a-z]{2}$'::"text"))
);




CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "friendship_code" "text" NOT NULL,
    CONSTRAINT "ck_users__friendship_code_format" CHECK (("friendship_code" ~ '^[0-9]{8}$'::"text")),
    CONSTRAINT "ck_users__name_length" CHECK ((("length"("name") >= 2) AND ("length"("name") <= 64)))
);




ALTER TABLE ONLY "public"."friendship_requests"
    ADD CONSTRAINT "pk_friendship_requests" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."friendships"
    ADD CONSTRAINT "pk_friendships" PRIMARY KEY ("user_id", "friend_id");



ALTER TABLE ONLY "public"."group_invitations"
    ADD CONSTRAINT "pk_group_invitations" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."group_users"
    ADD CONSTRAINT "pk_group_users" PRIMARY KEY ("group_id", "user_id");



ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "pk_groups" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."meme_laughs"
    ADD CONSTRAINT "pk_meme_laughs" PRIMARY KEY ("meme_id", "user_id");



ALTER TABLE ONLY "public"."meme_recipients"
    ADD CONSTRAINT "pk_meme_recipients" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."meme_templates"
    ADD CONSTRAINT "pk_meme_templates" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."memes"
    ADD CONSTRAINT "pk_memes" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "pk_notifications" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."push_device_tokens"
    ADD CONSTRAINT "pk_push_device_tokens" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "pk_users" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."meme_templates"
    ADD CONSTRAINT "uq_meme_templates__image_path" UNIQUE ("image_path");



ALTER TABLE ONLY "public"."memes"
    ADD CONSTRAINT "uq_memes__image_path" UNIQUE ("image_path");



ALTER TABLE ONLY "public"."memes"
    ADD CONSTRAINT "uq_memes__push_image_path" UNIQUE ("push_image_path");



ALTER TABLE ONLY "public"."notification_push_templates"
    ADD CONSTRAINT "uq_notification_push_templates_type_locale" UNIQUE NULLS NOT DISTINCT ("notification_type", "language_code", "country_code");



ALTER TABLE ONLY "public"."push_device_tokens"
    ADD CONSTRAINT "uq_push_device_tokens__fcm_token" UNIQUE ("fcm_token");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "uq_users__friendship_code" UNIQUE ("friendship_code");





































































































































































ALTER TABLE ONLY "public"."friendship_requests"
    ADD CONSTRAINT "fk_friendship_requests__addressee_id__auth_users__id" FOREIGN KEY ("addressee_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."friendship_requests"
    ADD CONSTRAINT "fk_friendship_requests__requester_id__auth_users__id" FOREIGN KEY ("requester_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."friendships"
    ADD CONSTRAINT "fk_friendships__friend_id__auth_users__id" FOREIGN KEY ("friend_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."friendships"
    ADD CONSTRAINT "fk_friendships__user_id__auth_users__id" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_invitations"
    ADD CONSTRAINT "fk_group_invitations__group_id__groups__id" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_invitations"
    ADD CONSTRAINT "fk_group_invitations__invitee_id__auth_users__id" FOREIGN KEY ("invitee_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_invitations"
    ADD CONSTRAINT "fk_group_invitations__inviter_id__auth_users__id" FOREIGN KEY ("inviter_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_users"
    ADD CONSTRAINT "fk_group_users__group_id__groups__id" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_users"
    ADD CONSTRAINT "fk_group_users__user_id__auth_users__id" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."meme_laughs"
    ADD CONSTRAINT "fk_meme_laughs__meme_id__memes__id" FOREIGN KEY ("meme_id") REFERENCES "public"."memes"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."meme_laughs"
    ADD CONSTRAINT "fk_meme_laughs__user_id__auth_users__id" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."meme_recipients"
    ADD CONSTRAINT "fk_meme_recipients__group_id__groups__id" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."meme_recipients"
    ADD CONSTRAINT "fk_meme_recipients__meme_id__memes__id" FOREIGN KEY ("meme_id") REFERENCES "public"."memes"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."meme_recipients"
    ADD CONSTRAINT "fk_meme_recipients__user_id__auth_users__id" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."memes"
    ADD CONSTRAINT "fk_memes__template_id__meme_templates__id" FOREIGN KEY ("template_id") REFERENCES "public"."meme_templates"("id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."memes"
    ADD CONSTRAINT "fk_memes__user_id__auth_users__id" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "fk_notifications__recipient_id__auth_users__id" FOREIGN KEY ("recipient_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."push_device_tokens"
    ADD CONSTRAINT "fk_push_device_tokens__user_id__auth_users__id" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "fk_users__id__auth_users__id" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



CREATE TABLE IF NOT EXISTS "public"."user_blocks" (
    "blocker_id" "uuid" NOT NULL,
    "blocked_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "pk_user_blocks" PRIMARY KEY ("blocker_id", "blocked_id"),
    CONSTRAINT "ck_user_blocks_not_self" CHECK (("blocker_id" <> "blocked_id")),
    CONSTRAINT "fk_user_blocks_blocker_id__auth_users__id" FOREIGN KEY ("blocker_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "fk_user_blocks_blocked_id__auth_users__id" FOREIGN KEY ("blocked_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS "public"."ugc_reports" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "reporter_id" "uuid" NOT NULL,
    "target_type" "public"."ugc_report_target_type" NOT NULL,
    "target_user_id" "uuid",
    "target_group_id" "uuid",
    "target_meme_id" "uuid",
    "reason" "public"."ugc_report_reason" NOT NULL,
    "status" "public"."ugc_report_status" DEFAULT 'open'::"public"."ugc_report_status" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "pk_ugc_reports" PRIMARY KEY ("id"),
    CONSTRAINT "ck_ugc_reports_target_shape" CHECK ((((("target_type" = 'user'::"public"."ugc_report_target_type") AND ("target_user_id" IS NOT NULL) AND ("target_group_id" IS NULL) AND ("target_meme_id" IS NULL)) OR (("target_type" = 'group'::"public"."ugc_report_target_type") AND ("target_user_id" IS NULL) AND ("target_group_id" IS NOT NULL) AND ("target_meme_id" IS NULL)) OR (("target_type" = 'meme'::"public"."ugc_report_target_type") AND ("target_user_id" IS NULL) AND ("target_group_id" IS NULL) AND ("target_meme_id" IS NOT NULL))))),
    CONSTRAINT "fk_ugc_reports_reporter" FOREIGN KEY ("reporter_id") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "fk_ugc_reports_target_user" FOREIGN KEY ("target_user_id") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "fk_ugc_reports_target_group" FOREIGN KEY ("target_group_id") REFERENCES "public"."groups"("id") ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "fk_ugc_reports_target_meme" FOREIGN KEY ("target_meme_id") REFERENCES "public"."memes"("id") ON UPDATE CASCADE ON DELETE CASCADE
);
