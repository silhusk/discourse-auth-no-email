require 'rails_helper'

describe "auth-no-email plugin" do

  let(:email) { "email@example.com" }
  before do
    SiteSetting.enable_local_logins = false
    SiteSetting.enable_google_oauth2_logins = true
    OmniAuth.config.test_mode = true
    SiteSetting.auth_no_email_enabled = true

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '123545',
      info: OmniAuth::AuthHash::InfoHash.new(
        email: email
      ),
      extra: {
        raw_info: OmniAuth::AuthHash.new(
          email_verified: true
        )
      }
    )

    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
  end

  after do
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.test_mode = false
  end

  it "does nothing when disabled" do
    SiteSetting.auth_no_email_enabled = false
    get "/auth/google_oauth2/callback"
    data = JSON.parse(cookies[:authentication_data])
    expect(data["email"]).to eq(email)
    expect(data["username"]).to eq("email") # suggested by UsernameSuggester
  end

  it "does not prevent matching by email when disabled" do
    SiteSetting.auth_no_email_enabled = false
    user = Fabricate(:user, email: email)
    get "/auth/google_oauth2/callback"
    expect(response.status).to eq(302)
    expect(session[:current_user_id]).to eq(user.id)
  end

  it "returns fake email when enabled" do
    get "/auth/google_oauth2/callback"
    expect(response.status).to eq(302)
    data = JSON.parse(cookies[:authentication_data])
    expect(data["email"]).to include("@no-email.invalid")
  end

  it "prevents matching by email when disabled" do
    user = Fabricate(:user, email: email)
    get "/auth/google_oauth2/callback"
    expect(response.status).to eq(302)
    expect(session[:current_user_id]).to eq(nil)
  end

  it "prevents username being suggested from email" do
    get "/auth/google_oauth2/callback"
    expect(response.status).to eq(302)
    data = JSON.parse(cookies[:authentication_data])
    expect(data["username"]).to eq(nil)
  end
end
