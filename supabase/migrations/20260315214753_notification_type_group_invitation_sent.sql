-- -----------------------------------------------------------------------------
-- Notification type extension
-- -----------------------------------------------------------------------------
--
-- Keep this in a dedicated migration so the new enum label is committed before
-- later migrations reference it in constraints/functions/inserts.
alter type public.notification_type
  add value if not exists 'group_invitation_sent';
