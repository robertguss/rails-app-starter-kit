class PasswordRecoveryService
  def self.request(email)
    user = User.find_by(email_address: email.to_s.strip.downcase)
    return unless user&.access_active? && user.password_digest.present?
    _record, raw = TokenIssuer.issue!(user.password_recoveries)
    AccessMailer.recovery(user, raw).deliver_later
  end

  def self.reset!(token:, password:, password_confirmation: password)
    PasswordRecovery.transaction do
      recovery = PasswordRecovery.lock.find_by!(token_digest: TokenDigest.call(token))
      raise ActiveRecord::RecordNotFound unless recovery.consumed_at.nil? && recovery.revoked_at.nil? && recovery.expires_at.future? && recovery.user.access_active?
      recovery.user.update!(password:, password_confirmation:)
      recovery.user.sessions.live.update_all(revoked_at: Time.current)
      recovery.update!(consumed_at: Time.current)
      AuditEvent.record!(actor: recovery.user, action: "password.recovered", subject: recovery.user)
    end
  end
end
