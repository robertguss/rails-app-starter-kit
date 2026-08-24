# frozen_string_literal: true

require "test_helper"

class PurgeExpiredSessionsJobTest < ActiveJob::TestCase
  setup do
    [ AuditEvent, Session, Identity, AccessGrant, User ].each(&:delete_all)
    @owner = User.new(email_address: "owner@example.test", name: "Owner", role: :owner)
    @owner.password = "long-password" if @owner.respond_to?(:password=)
    @owner.save!
    AccessGrant.create!(normalized_email: @owner.email_address, granted_by: @owner, granted_at: Time.current, claimed_by: @owner, claimed_at: Time.current)
  end

  test "repeated execution only revokes sessions after their fixed expiry once" do
    expired, = Session.issue!(user: @owner)
    travel 31.days do
      live, = Session.issue!(user: @owner)
      cutoff = Time.current

      2.times { PurgeExpiredSessionsJob.perform_now(cutoff) }

      assert_equal cutoff.to_i, expired.reload.revoked_at.to_i
      assert live.reload.live?
    end
  end
end
