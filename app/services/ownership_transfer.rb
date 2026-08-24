class OwnershipTransfer
  def self.call!(actor:, recipient:)
    User.transaction do
      owner = User.lock.find_by!(role: "owner")
      recipient.lock!
      raise ActiveRecord::RecordNotFound unless owner == actor && recipient.access_active? && recipient.member?

      Session.live.where(user_id: [ owner.id, recipient.id ]).update_all(revoked_at: Time.current)
      User.where(id: owner.id).update_all(role: "member", updated_at: Time.current)
      recipient.update!(role: "owner")
      AuditEvent.record!(actor:, action: "owner.transferred", subject: recipient)
    end
  end
end
