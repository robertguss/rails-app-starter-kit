class GoogleAuthenticator
  class Denied < StandardError; end

  def self.call!(auth, user_agent: nil, ip_address: nil)
    subject = auth["uid"].presence
    info = auth.fetch("info", {})
    extra = auth.dig("extra", "id_info") || auth.dig("extra", "raw_info") || {}
    email = info["email"].to_s.strip.downcase
    verified = info["email_verified"] == true || extra["email_verified"] == true
    domains = ENV.fetch("GOOGLE_WORKSPACE_DOMAINS", "").split(",").map(&:strip).reject(&:blank?)
    hd = extra["hd"].to_s.downcase
    raise Denied if subject.blank? || email.blank? || !verified || domains.empty? || !domains.include?(hd)

    Identity.transaction do
      identity = Identity.lock.find_by(provider: "google", provider_subject: subject)
      if identity
        raise Denied unless identity.user.access_active?
        user = identity.user
      else
        grant = AccessGrant.lock.find_by(normalized_email: email, active: true)
        raise Denied unless grant
        user = grant.claimed_by
        existing_identity = user&.identities&.find_by(provider: "google")
        raise Denied if existing_identity && existing_identity.provider_subject != subject

        user ||= User.create!(email_address: email, name: info["name"].presence || email, passwordless: true)
        grant.update!(claimed_by: user, claimed_at: Time.current) unless grant.claimed_by
        Identity.create!(user:, provider: "google", provider_subject: subject, provider_email: email, metadata: { "hd" => hd })
      end

      session, raw_session_token = Session.issue!(user:, user_agent:, ip_address:)
      AuditEvent.record!(actor: user, action: "google.login", subject: user)
      [ user, session, raw_session_token ]
    end
  end
end
