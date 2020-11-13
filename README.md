## discourse-auth-no-email

This will fake and hide user emails from omniauth login methods. This should be used in conjunction with sso_overrides_email=true, disable_emails=yes and enable_local_logins=false

Behind the scenes, users are assigned email addresses like `{uid-hash}@no-email.invalid`. This is hidden from users using CSS. 