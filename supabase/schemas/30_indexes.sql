CREATE INDEX "friendship_requests_inbox_pending_idx" ON "public"."friendship_requests" USING "btree" ("addressee_id") WHERE ("status" = 'pending'::"public"."friendship_request_status");

CREATE UNIQUE INDEX "friendship_requests_one_pending_per_pair" ON "public"."friendship_requests" USING "btree" ("pair_low", "pair_high") WHERE ("status" = 'pending'::"public"."friendship_request_status");

CREATE INDEX "friendship_requests_outbox_pending_idx" ON "public"."friendship_requests" USING "btree" ("requester_id") WHERE ("status" = 'pending'::"public"."friendship_request_status");

CREATE INDEX "friendship_requests_pair_pending_lookup_idx" ON "public"."friendship_requests" USING "btree" ("requester_id", "addressee_id") WHERE ("status" = 'pending'::"public"."friendship_request_status");

CREATE INDEX "friendships_user_id_created_at_friend_id_idx" ON "public"."friendships" USING "btree" ("user_id", "created_at" DESC, "friend_id" DESC);

CREATE INDEX "group_invitations_group_pending_idx" ON "public"."group_invitations" USING "btree" ("group_id", "created_at" DESC, "id" DESC) WHERE ("status" = 'pending'::"public"."group_invitation_status");

CREATE INDEX "group_invitations_invitee_pending_idx" ON "public"."group_invitations" USING "btree" ("invitee_id", "created_at" DESC, "id" DESC) WHERE ("status" = 'pending'::"public"."group_invitation_status");

CREATE UNIQUE INDEX "group_invitations_one_pending_per_group_invitee_uidx" ON "public"."group_invitations" USING "btree" ("group_id", "invitee_id") WHERE ("status" = 'pending'::"public"."group_invitation_status");

CREATE INDEX "group_users_group_id_created_at_user_id_idx" ON "public"."group_users" USING "btree" ("group_id", "created_at" DESC, "user_id" DESC);

CREATE UNIQUE INDEX "group_users_one_creator_per_group_uidx" ON "public"."group_users" USING "btree" ("group_id") WHERE ("type" = 'creator'::"public"."group_user_type");

CREATE INDEX "group_users_user_id_created_at_group_id_idx" ON "public"."group_users" USING "btree" ("user_id", "created_at" DESC, "group_id" DESC);

CREATE INDEX "groups_created_at_id_idx" ON "public"."groups" USING "btree" ("created_at" DESC, "id" DESC);

CREATE INDEX "meme_laughs_meme_id_created_at_user_id_idx" ON "public"."meme_laughs" USING "btree" ("meme_id", "created_at" DESC, "user_id" DESC);

CREATE INDEX "meme_laughs_user_id_meme_id_idx" ON "public"."meme_laughs" USING "btree" ("user_id", "meme_id");

CREATE INDEX "meme_recipients_group_id_meme_id_idx" ON "public"."meme_recipients" USING "btree" ("group_id", "meme_id") WHERE ("group_id" IS NOT NULL);

CREATE INDEX "meme_recipients_meme_id_created_at_id_idx" ON "public"."meme_recipients" USING "btree" ("meme_id", "created_at" DESC, "id" DESC);

CREATE UNIQUE INDEX "meme_recipients_meme_id_group_id_uidx" ON "public"."meme_recipients" USING "btree" ("meme_id", "group_id") WHERE ("group_id" IS NOT NULL);

CREATE UNIQUE INDEX "meme_recipients_meme_id_user_id_uidx" ON "public"."meme_recipients" USING "btree" ("meme_id", "user_id") WHERE ("user_id" IS NOT NULL);

CREATE INDEX "meme_recipients_user_id_meme_id_idx" ON "public"."meme_recipients" USING "btree" ("user_id", "meme_id") WHERE ("user_id" IS NOT NULL);

CREATE INDEX "meme_templates_created_at_id_idx" ON "public"."meme_templates" USING "btree" ("created_at" DESC, "id" DESC);

CREATE INDEX "meme_templates_tags_idx" ON "public"."meme_templates" USING "gin" ("tags");

CREATE INDEX "meme_templates_tags_search_text_trgm_idx" ON "public"."meme_templates" USING "gin" ("tags_search_text" "extensions"."gin_trgm_ops");

CREATE INDEX "memes_created_at_id_idx" ON "public"."memes" USING "btree" ("created_at" DESC, "id" DESC);

CREATE INDEX "memes_user_id_created_at_id_idx" ON "public"."memes" USING "btree" ("user_id", "created_at" DESC, "id" DESC);

CREATE UNIQUE INDEX "notifications_meme_received_recipient_meme_id_uidx" ON "public"."notifications" USING "btree" ("recipient_id", (("data" ->> 'meme_id'::"text")), (COALESCE(("data" ->> 'group_id'::"text"), '__direct__'::"text"))) WHERE ("type" = 'meme_received'::"public"."notification_type");

CREATE INDEX "notifications_recipient_created_at_id_idx" ON "public"."notifications" USING "btree" ("recipient_id", "created_at" DESC, "id" DESC);

CREATE INDEX "notifications_recipient_unread_created_at_id_idx" ON "public"."notifications" USING "btree" ("recipient_id", "created_at" DESC, "id" DESC) WHERE ("is_read" = false);

CREATE INDEX "push_device_tokens_cleanup_idx" ON "public"."push_device_tokens" USING "btree" ("is_active", "deactivated_at") WHERE ("is_active" = false);

CREATE UNIQUE INDEX "push_device_tokens_one_active_per_installation_idx" ON "public"."push_device_tokens" USING "btree" ("installation_id") WHERE ("is_active" = true);

CREATE INDEX "push_device_tokens_user_active_last_seen_idx" ON "public"."push_device_tokens" USING "btree" ("user_id", "is_active", "last_seen_at" DESC);

CREATE INDEX "user_blocks_blocked_id_idx" ON "public"."user_blocks" USING "btree" ("blocked_id");

CREATE INDEX "user_blocks_blocker_created_at_blocked_id_idx" ON "public"."user_blocks" USING "btree" ("blocker_id", "created_at" DESC, "blocked_id" DESC);

CREATE INDEX "ugc_reports_reporter_created_at_idx" ON "public"."ugc_reports" USING "btree" ("reporter_id", "created_at" DESC, "id" DESC);

CREATE UNIQUE INDEX "ugc_reports_active_user_report_per_reporter_target_uidx" ON "public"."ugc_reports" USING "btree" ("reporter_id", "target_user_id") WHERE (("target_type" = 'user'::"public"."ugc_report_target_type") AND ("target_user_id" IS NOT NULL) AND ("status" = ANY (ARRAY['open'::"public"."ugc_report_status", 'in_review'::"public"."ugc_report_status"])));

CREATE INDEX "ugc_reports_target_user_created_at_idx" ON "public"."ugc_reports" USING "btree" ("target_user_id", "created_at" DESC, "id" DESC) WHERE ("target_user_id" IS NOT NULL);

CREATE INDEX "ugc_reports_target_group_created_at_idx" ON "public"."ugc_reports" USING "btree" ("target_group_id", "created_at" DESC, "id" DESC) WHERE ("target_group_id" IS NOT NULL);

CREATE INDEX "ugc_reports_target_meme_created_at_idx" ON "public"."ugc_reports" USING "btree" ("target_meme_id", "created_at" DESC, "id" DESC) WHERE ("target_meme_id" IS NOT NULL);
