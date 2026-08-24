module Settings
  class AccessController < ApplicationController
    before_action :require_authentication
    before_action :require_owner
    def index
      render inertia: "settings/access", props: { grants: AccessGrant.includes(:claimed_by).order(:normalized_email).map { |g| { id: g.id, email: g.normalized_email, active: g.active, name: g.claimed_by&.name, role: g.claimed_by&.role } } }
    end
    def create
      grant = AccessGrant.find_or_initialize_by(normalized_email: params[:email].to_s.strip.downcase)
      grant.update!(active: true, granted_by: Current.user, granted_at: Time.current, revoked_at: nil, revoked_by: nil)
      if Authentication.method_enabled?(:password) && Rails.configuration.x.mail_delivery_enabled
        _invitation, raw = TokenIssuer.issue!(grant.invitations)
        AccessMailer.invitation(grant, raw).deliver_later
      end
      AuditEvent.record!(actor: Current.user, action: "access.granted", subject: grant)
      notice = if Authentication.method_enabled?(:password) && Rails.configuration.x.mail_delivery_enabled
        "Access granted and invitation sent."
      else
        "Access granted. Use the access command when no mail transport is configured."
      end
      redirect_to settings_access_path, notice:
    end
    def destroy
      AccessGrant.find(params[:id]).revoke!(actor: Current.user)
      redirect_to settings_access_path, notice: "Access revoked."
    end
    def transfer
      grant = AccessGrant.lock.find(params[:id])
      OwnershipTransfer.call!(actor: Current.user, recipient: grant.claimed_by || raise(ActiveRecord::RecordNotFound))
      terminate_session
      redirect_to login_path, notice: "Ownership transferred. Sign in again."
    end
    private
      def require_owner
        head :forbidden unless Current.user&.owner?
      end
  end
end
