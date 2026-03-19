CREATE OR REPLACE TRIGGER "dbwebhook_memes_insert_generate_push_preview" AFTER INSERT ON "public"."memes" FOR EACH ROW EXECUTE FUNCTION "public"."enqueue_generate_meme_push_preview"();

CREATE OR REPLACE TRIGGER "dbwebhook_notifications_insert_send_push" AFTER INSERT ON "public"."notifications" FOR EACH ROW EXECUTE FUNCTION "public"."enqueue_send_notification_push"();

CREATE OR REPLACE TRIGGER "trg_friendship_requests__create_notification_on_accepted" AFTER UPDATE OF "status" ON "public"."friendship_requests" FOR EACH ROW EXECUTE FUNCTION "public"."create_notification_on_friendship_request_accepted"();

CREATE OR REPLACE TRIGGER "trg_friendship_requests__create_notification_on_insert" AFTER INSERT ON "public"."friendship_requests" FOR EACH ROW EXECUTE FUNCTION "public"."create_notification_on_friendship_request_sent"();

CREATE OR REPLACE TRIGGER "trg_friendship_requests__sync_friendships_on_accepted" AFTER INSERT OR UPDATE OF "status" ON "public"."friendship_requests" FOR EACH ROW EXECUTE FUNCTION "public"."sync_friendships_from_accepted_request"();

CREATE OR REPLACE TRIGGER "trg_friendship_requests__touch_updated_at" BEFORE UPDATE ON "public"."friendship_requests" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();

CREATE OR REPLACE TRIGGER "trg_friendships__touch_updated_at" BEFORE UPDATE ON "public"."friendships" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();

CREATE OR REPLACE TRIGGER "trg_group_invitations__create_notification_on_insert" AFTER INSERT ON "public"."group_invitations" FOR EACH ROW EXECUTE FUNCTION "public"."create_notification_on_group_invitation_sent"();

CREATE OR REPLACE TRIGGER "trg_group_invitations__sync_group_users_on_accepted" AFTER INSERT OR UPDATE OF "status" ON "public"."group_invitations" FOR EACH ROW EXECUTE FUNCTION "public"."sync_group_users_from_accepted_invitation"();

CREATE OR REPLACE TRIGGER "trg_group_invitations__touch_updated_at" BEFORE UPDATE ON "public"."group_invitations" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();

CREATE OR REPLACE TRIGGER "trg_group_users__cleanup_after_delete" AFTER DELETE ON "public"."group_users" FOR EACH ROW EXECUTE FUNCTION "public"."cleanup_group_after_user_removed"();

CREATE OR REPLACE TRIGGER "trg_group_users__touch_updated_at" BEFORE UPDATE ON "public"."group_users" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();

CREATE OR REPLACE TRIGGER "trg_groups__touch_updated_at" BEFORE UPDATE ON "public"."groups" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();

CREATE OR REPLACE TRIGGER "trg_meme_laughs__create_notification_on_insert" AFTER INSERT ON "public"."meme_laughs" FOR EACH ROW EXECUTE FUNCTION "public"."create_notification_on_meme_laughed"();

CREATE OR REPLACE TRIGGER "trg_meme_laughs__touch_updated_at" BEFORE UPDATE ON "public"."meme_laughs" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();

CREATE OR REPLACE TRIGGER "trg_meme_recipients__cleanup_meme_after_delete" AFTER DELETE ON "public"."meme_recipients" FOR EACH ROW EXECUTE FUNCTION "public"."cleanup_meme_after_recipient_removed"();

CREATE OR REPLACE TRIGGER "trg_meme_recipients__touch_updated_at" BEFORE UPDATE ON "public"."meme_recipients" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();

CREATE OR REPLACE TRIGGER "trg_meme_templates__sync_tags_search_text" BEFORE INSERT OR UPDATE OF "tags" ON "public"."meme_templates" FOR EACH ROW EXECUTE FUNCTION "public"."sync_meme_template_tags_search_text"();

CREATE OR REPLACE TRIGGER "trg_meme_templates__touch_updated_at" BEFORE UPDATE ON "public"."meme_templates" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();

CREATE OR REPLACE TRIGGER "trg_memes__create_notifications_on_preview_resolved" AFTER UPDATE OF "push_preview_status" ON "public"."memes" FOR EACH ROW EXECUTE FUNCTION "public"."create_notifications_on_meme_preview_resolved"();

CREATE OR REPLACE TRIGGER "trg_memes__touch_updated_at" BEFORE UPDATE ON "public"."memes" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();

CREATE OR REPLACE TRIGGER "trg_notification_push_templates__touch_updated_at" BEFORE UPDATE ON "public"."notification_push_templates" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();

CREATE OR REPLACE TRIGGER "trg_notifications__touch_updated_at" BEFORE UPDATE ON "public"."notifications" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();

CREATE OR REPLACE TRIGGER "trg_push_device_tokens__touch_updated_at" BEFORE UPDATE ON "public"."push_device_tokens" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();

CREATE OR REPLACE TRIGGER "trg_users__touch_updated_at" BEFORE UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."touch_updated_at"();
