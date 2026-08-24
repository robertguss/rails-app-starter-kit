# frozen_string_literal: true

class InvitationAcceptance
  def self.call!(token:, name:, password:, password_confirmation: password, user_agent: nil, ip_address: nil)
    Invitation.transaction do
      invitation = Invitation.lock.find_by!(token_digest: TokenDigest.call(token))
      grant = AccessGrant.lock.find(invitation.access_grant_id)
      raise ActiveRecord::RecordNotFound unless invitation.consumed_at.nil? && invitation.revoked_at.nil? && invitation.expires_at.future? && grant.active? && grant.claimed_by_id.nil?
      user = User.create!(email_address: grant.normalized_email, name:, password:, password_confirmation:)
      grant.update!(claimed_by: user, claimed_at: Time.current)
      invitation.update!(consumed_at: Time.current)
      session, raw_session_token = Session.issue!(user:, user_agent:, ip_address:)
      AuditEvent.record!(actor: user, action: "invitation.accepted", subject: grant)
      [ user, session, raw_session_token ]
    end
  end
end
