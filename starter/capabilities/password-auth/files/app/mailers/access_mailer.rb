# frozen_string_literal: true

class AccessMailer < ApplicationMailer
  def invitation(grant, token)
    @url = invitation_url(token:)
    mail(to: grant.normalized_email, subject: "Your invitation")
  end
  def recovery(user, token)
    @url = edit_password_recovery_url(token:)
    mail(to: user.email_address, subject: "Password recovery")
  end
end
