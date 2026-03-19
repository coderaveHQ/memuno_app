CREATE SCHEMA IF NOT EXISTS "public";







CREATE TYPE "public"."user_item" AS (
	"id" "uuid",
	"name" "text",
	"friendship_code" "text",
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone
);




CREATE TYPE "public"."friendship_item" AS (
	"user" "public"."user_item",
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone
);




CREATE TYPE "public"."friendship_request_direction" AS ENUM (
    'outgoing',
    'incoming'
);




CREATE TYPE "public"."friendship_request_status" AS ENUM (
    'pending',
    'accepted',
    'declined',
    'canceled'
);




CREATE TYPE "public"."friendship_request_item" AS (
	"id" "uuid",
	"status" "public"."friendship_request_status",
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone,
	"direction" "public"."friendship_request_direction",
	"user" "public"."user_item"
);




CREATE TYPE "public"."group_user_type" AS ENUM (
    'creator',
    'admin',
    'member'
);




CREATE TYPE "public"."group_details" AS (
	"id" "uuid",
	"name" "text",
	"member_count" integer,
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone,
	"my_user_type" "public"."group_user_type",
	"is_member" boolean,
	"has_pending_invitation" boolean,
	"can_manage_members" boolean,
	"can_add_members" boolean,
	"can_delete_group" boolean
);




CREATE TYPE "public"."group_invitation_status" AS ENUM (
    'pending',
    'accepted',
    'rejected',
    'canceled'
);




CREATE TYPE "public"."group_item" AS (
	"id" "uuid",
	"name" "text",
	"member_count" integer,
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone
);




CREATE TYPE "public"."group_invitation_item" AS (
	"id" "uuid",
	"status" "public"."group_invitation_status",
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone,
	"group" "public"."group_item",
	"inviter" "public"."user_item"
);




CREATE TYPE "public"."group_member_item" AS (
	"type" "public"."group_user_type",
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone,
	"user" "public"."user_item"
);




CREATE TYPE "public"."group_pending_invitation_item" AS (
	"id" "uuid",
	"status" "public"."group_invitation_status",
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone,
	"invitee" "public"."user_item",
	"inviter" "public"."user_item"
);




CREATE TYPE "public"."list_page" AS (
	"items" "jsonb",
	"next_cursor_created_at" timestamp with time zone,
	"next_cursor_id" "uuid"
);




CREATE TYPE "public"."meme_item" AS (
	"id" "uuid",
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone,
	"image_path" "text",
	"aspect_ratio" double precision,
	"laugh_count" integer,
	"is_laughed" boolean,
	"user" "public"."user_item"
);




CREATE TYPE "public"."meme_laugh_item" AS (
	"user" "public"."user_item",
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone
);




CREATE TYPE "public"."meme_recipient_target_type" AS ENUM (
    'user',
    'group'
);




CREATE TYPE "public"."meme_recipient_target_item" AS (
	"type" "public"."meme_recipient_target_type",
	"id" "uuid",
	"name" "text",
	"friendship_code" "text",
	"member_count" integer,
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone
);




CREATE TYPE "public"."meme_template_item" AS (
	"id" "uuid",
	"image_path" "text",
	"aspect_ratio" double precision,
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone
);




CREATE TYPE "public"."notification_type" AS ENUM (
    'friendship_request_sent',
    'friendship_request_accepted',
    'meme_received',
    'meme_laughed',
    'group_invitation_sent'
);




CREATE TYPE "public"."notification_item" AS (
	"id" "uuid",
	"type" "public"."notification_type",
	"data" "jsonb",
	"is_read" boolean,
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone
);




CREATE TYPE "public"."push_platform" AS ENUM (
    'ios',
    'android'
);




CREATE TYPE "public"."push_preview_status" AS ENUM (
    'pending',
    'ready',
    'failed'
);




CREATE TYPE "public"."push_token_deactivation_reason" AS ENUM (
    'signed_out',
    'token_rotated',
    'permission_revoked',
    'send_invalid',
    'account_deleted',
    'cleanup'
);




CREATE TYPE "public"."user_profile_item" AS (
	"id" "uuid",
	"name" "text",
	"friendship_code" "text",
	"created_at" timestamp with time zone,
	"updated_at" timestamp with time zone,
	"is_friend" boolean,
	"has_pending_friendship_request" boolean
);




