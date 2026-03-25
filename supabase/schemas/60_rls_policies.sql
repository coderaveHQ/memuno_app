ALTER TABLE "public"."friendship_requests" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "friendship_requests:insert:requester:authenticated" ON "public"."friendship_requests" FOR INSERT TO "authenticated" WITH CHECK (("requester_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "friendship_requests:select:participant:authenticated" ON "public"."friendship_requests" FOR SELECT TO "authenticated" USING ((("requester_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("addressee_id" = ( SELECT "auth"."uid"() AS "uid"))));



CREATE POLICY "friendship_requests:update:participant:authenticated" ON "public"."friendship_requests" FOR UPDATE TO "authenticated" USING ((("requester_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("addressee_id" = ( SELECT "auth"."uid"() AS "uid")))) WITH CHECK ((("requester_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("addressee_id" = ( SELECT "auth"."uid"() AS "uid"))));



ALTER TABLE "public"."friendships" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "friendships:delete:self:authenticated" ON "public"."friendships" FOR DELETE TO "authenticated" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "friendships:insert:self:authenticated" ON "public"."friendships" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "friendships:select:self:authenticated" ON "public"."friendships" FOR SELECT TO "authenticated" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."group_invitations" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "group_invitations:select:participant:authenticated" ON "public"."group_invitations" FOR SELECT TO "authenticated" USING ((("inviter_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("invitee_id" = ( SELECT "auth"."uid"() AS "uid"))));



ALTER TABLE "public"."group_users" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "group_users:select:member:authenticated" ON "public"."group_users" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."group_users" "me"
  WHERE (("me"."group_id" = "group_users"."group_id") AND ("me"."user_id" = ( SELECT "auth"."uid"() AS "uid"))))));



ALTER TABLE "public"."groups" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "groups:select:member:authenticated" ON "public"."groups" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."group_users" "gu"
  WHERE (("gu"."group_id" = "groups"."id") AND ("gu"."user_id" = ( SELECT "auth"."uid"() AS "uid"))))));



ALTER TABLE "public"."meme_laughs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "meme_laughs:delete:self:authenticated" ON "public"."meme_laughs" FOR DELETE TO "authenticated" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "meme_laughs:insert:self_viewable_meme:authenticated" ON "public"."meme_laughs" FOR INSERT TO "authenticated" WITH CHECK ((("user_id" = ( SELECT "auth"."uid"() AS "uid")) AND "public"."can_view_meme"("meme_id", ( SELECT "auth"."uid"() AS "uid")) AND (NOT "public"."is_meme_creator"("meme_id", ( SELECT "auth"."uid"() AS "uid")))));



CREATE POLICY "meme_laughs:select:viewable_meme:authenticated" ON "public"."meme_laughs" FOR SELECT TO "authenticated" USING ("public"."can_view_meme_laugh_actor"("meme_id", ( SELECT "auth"."uid"() AS "uid"), "user_id"));



ALTER TABLE "public"."meme_recipients" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "meme_recipients:insert:owner:authenticated" ON "public"."meme_recipients" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."memes" "m"
  WHERE (("m"."id" = "meme_recipients"."meme_id") AND ("m"."user_id" = ( SELECT "auth"."uid"() AS "uid"))))));



CREATE POLICY "meme_recipients:select:self:authenticated" ON "public"."meme_recipients" FOR SELECT TO "authenticated" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."meme_templates" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "meme_templates:select:active:authenticated" ON "public"."meme_templates" FOR SELECT TO "authenticated" USING (("is_active" = true));



ALTER TABLE "public"."memes" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "memes:insert:owner:authenticated" ON "public"."memes" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "memes:select:owner_or_recipient:authenticated" ON "public"."memes" FOR SELECT TO "authenticated" USING ((("user_id" = ( SELECT "auth"."uid"() AS "uid")) OR "public"."is_meme_recipient"("id", ( SELECT "auth"."uid"() AS "uid"))));



ALTER TABLE "public"."notification_push_templates" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "notifications:select:recipient:authenticated" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("recipient_id" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."push_device_tokens" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "push_device_tokens:delete:self:authenticated" ON "public"."push_device_tokens" FOR DELETE TO "authenticated" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "push_device_tokens:insert:self:authenticated" ON "public"."push_device_tokens" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "push_device_tokens:select:self:authenticated" ON "public"."push_device_tokens" FOR SELECT TO "authenticated" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "push_device_tokens:update:self:authenticated" ON "public"."push_device_tokens" FOR UPDATE TO "authenticated" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "users:select:self:authenticated" ON "public"."users" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "users:update:self:authenticated" ON "public"."users" FOR UPDATE TO "authenticated" USING (("id" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("id" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."user_blocks" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_blocks:insert:self:authenticated" ON "public"."user_blocks" FOR INSERT TO "authenticated" WITH CHECK (("blocker_id" = ( SELECT "auth"."uid"() AS "uid")));

CREATE POLICY "user_blocks:select:self:authenticated" ON "public"."user_blocks" FOR SELECT TO "authenticated" USING (("blocker_id" = ( SELECT "auth"."uid"() AS "uid")));

CREATE POLICY "user_blocks:delete:self:authenticated" ON "public"."user_blocks" FOR DELETE TO "authenticated" USING (("blocker_id" = ( SELECT "auth"."uid"() AS "uid")));

ALTER TABLE "public"."ugc_reports" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ugc_reports:insert:self:authenticated" ON "public"."ugc_reports" FOR INSERT TO "authenticated" WITH CHECK (("reporter_id" = ( SELECT "auth"."uid"() AS "uid")));

CREATE POLICY "ugc_reports:select:self:authenticated" ON "public"."ugc_reports" FOR SELECT TO "authenticated" USING (("reporter_id" = ( SELECT "auth"."uid"() AS "uid")));
