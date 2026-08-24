if Rails.env.development? || (!Rails.env.production? && ENV["AGENT_LOGIN_ENABLED"] == "1")
  User.transaction do
    [ [ "owner@example.test", "Agent Owner", "owner" ], [ "member@example.test", "Agent Member", "member" ], [ "second@example.test", "Agent Second", "member" ] ].each do |email, name, role|
      user = User.find_or_initialize_by(email_address: email)
      user.update!(name:, role:, active: true)
      grant = AccessGrant.find_or_initialize_by(normalized_email: email)
      grant.update!(active: true, granted_by: User.owner.first || user, granted_at: grant.granted_at || Time.current, claimed_by: user, claimed_at: grant.claimed_at || Time.current, revoked_at: nil, revoked_by: nil)
    end
  end
end
