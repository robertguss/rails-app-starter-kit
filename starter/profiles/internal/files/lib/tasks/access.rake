# Workspace-only closed-access operator commands.
namespace :access do
  desc "Interactively bootstrap the only owner"
  task bootstrap: :environment do
    abort "An owner already exists" if User.owner.exists?
    email = ENV.fetch("EMAIL").strip.downcase
    name = ENV.fetch("NAME", email)

    User.transaction do
      user = User.create!(email_address: email, name:, role: :owner)
      AccessGrant.create!(normalized_email: email, active: true, granted_by: user, granted_at: Time.current, claimed_by: user, claimed_at: Time.current)
    end
    puts "Bootstrapped owner #{email}"
  end

  desc "Grant an email access"
  task :grant, [ :email ] => :environment do |_task, args|
    email = args.fetch(:email).strip.downcase
    grant = AccessGrant.find_or_initialize_by(normalized_email: email)
    grant.update!(active: true, granted_by: User.owner.first!, granted_at: Time.current, revoked_at: nil, revoked_by: nil)
    puts "Granted #{email}"
  end

  task :revoke, [ :email ] => :environment do |_task, args|
    AccessGrant.find_by!(normalized_email: args.fetch(:email).strip.downcase).revoke!(actor: nil)
  end
end
