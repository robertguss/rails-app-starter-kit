namespace :access do
  desc "Interactively bootstrap the only owner"
  task bootstrap: :environment do
    abort "An owner already exists" if User.owner.exists?
    require "io/console"
    print "Email: "; email = $stdin.gets&.strip
    print "Name: "; name = $stdin.gets&.strip
    print "Password: "; password = $stdin.noecho(&:gets)&.strip; puts
    User.transaction do
      user = User.create!(email_address: email, name:, password:, password_confirmation: password, role: :owner)
      AccessGrant.create!(normalized_email: email, active: true, granted_by: user, granted_at: Time.current, claimed_by: user, claimed_at: Time.current)
      AuditEvent.record!(actor: user, action: "access.bootstrapped", subject: user)
    end
  end

  task :grant, [ :email ] => :environment do |_task, args|
    email = args.fetch(:email).strip.downcase
    grant = AccessGrant.find_or_initialize_by(normalized_email: email)
    grant.update!(active: true, granted_at: Time.current, revoked_at: nil, revoked_by: nil)
    if Authentication.method_enabled?(:password)
      _record, raw = TokenIssuer.issue!(grant.invitations)
      puts "Invitation token (deliver privately): #{raw}"
    else
      puts "Access granted for #{email}"
    end
  end

  task :revoke, [ :email ] => :environment do |_task, args|
    AccessGrant.find_by!(normalized_email: args.fetch(:email).strip.downcase).revoke!(actor: nil)
  end

  desc "Issue a private no-email password-recovery token"
  task :reset, [ :email ] => :environment do |_task, args|
    user = User.find_by!(email_address: args.fetch(:email).strip.downcase)
    abort "Password authentication is not enabled" unless Authentication.method_enabled?(:password)
    _record, raw = TokenIssuer.issue!(user.password_recoveries)
    puts "Recovery token (deliver privately): #{raw}"
  end
end
