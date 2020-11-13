# name: discourse-auth-no-email
# about: Remove the need for emails during signup via a managed authenticator
# version: 1.0
# authors: David Taylor
# url: https://github.com/discourse-org/discourse-auth-no-email

enabled_site_setting :auth_no_email_enabled

register_asset 'stylesheets/auth-no-email.scss'

on(:before_auth) do |authenticator, auth_token|
  next if !authenticator.is_managed?
  auth_token.info.email = nil # Prevent matching user by email
end

on(:after_auth) do |authenticator, result|
  next if !authenticator.is_managed?
  uid = result.extra_data[:uid]

  anonymised_uid = Digest::SHA1.hexdigest(uid.to_s)
  result.email = "#{anonymised_uid}@no-email.invalid"
  result.email_valid = true
  result.username = "" if result.username.nil? # Prevent a username being suggested based on email
end
