# frozen_string_literal: true

class TokenIssuer
  def self.issue!(relation, ttl: 24.hours)
    relation.proxy_association.owner.with_lock do
      raw = SecureRandom.urlsafe_base64(32)
      relation.live.update_all(revoked_at: Time.current)
      record = relation.create!(token_digest: TokenDigest.call(raw), expires_at: ttl.from_now)
      [ record, raw ]
    end
  end
end
