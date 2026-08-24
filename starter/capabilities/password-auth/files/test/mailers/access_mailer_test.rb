# frozen_string_literal: true

require "test_helper"
class AccessMailerTest < ActionMailer::TestCase
  test "invitation and recovery include raw token only in delivery" do
    user = User.create!(email_address: "mail@example.test", name: "Mail", password: "long-password", role: :owner)
    grant = AccessGrant.create!(normalized_email: user.email_address, granted_by: user, granted_at: Time.current, claimed_by: user, claimed_at: Time.current)
    assert_includes AccessMailer.invitation(grant, "raw-invite").body.encoded, "raw-invite"
    assert_includes AccessMailer.recovery(user, "raw-recovery").body.encoded, "raw-recovery"
    refute_includes user.attributes.to_json, "raw-recovery"
    refute_includes grant.attributes.to_json, "raw-invite"
  end
end
