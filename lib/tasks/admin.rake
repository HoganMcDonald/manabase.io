# frozen_string_literal: true

namespace :admin do
  desc "Make a user admin by email"
  task :grant, [:email] => :environment do |_t, args|
    if args[:email].blank?
      puts "Please provide an email address: rake 'admin:grant[user@example.com]'"
      exit 1
    end

    user = User.find_by(email: args[:email])

    if user.nil?
      puts "User with email '#{args[:email]}' not found."
      exit 1
    end

    if user.admin?
      puts "User '#{user.name}' (#{user.email}) is already an admin."
    else
      user.update!(admin: true)
      puts "✅ User '#{user.name}' (#{user.email}) has been granted admin privileges."
    end
  end

  desc "Revoke admin privileges from a user by email"
  task :revoke, [:email] => :environment do |_t, args|
    if args[:email].blank?
      puts "Please provide an email address: rake 'admin:revoke[user@example.com]'"
      exit 1
    end

    user = User.find_by(email: args[:email])

    if user.nil?
      puts "User with email '#{args[:email]}' not found."
      exit 1
    end

    if user.admin?
      user.update!(admin: false)
      puts "✅ Admin privileges revoked from '#{user.name}' (#{user.email})."
    else
      puts "User '#{user.name}' (#{user.email}) is not an admin."
    end
  end

  desc "List all admin users"
  task list: :environment do
    admins = User.where(admin: true)

    if admins.empty?
      puts "No admin users found."
    else
      puts "Admin users:"
      puts "=" * 50
      admins.each do |admin|
        puts "• #{admin.name} (#{admin.email}) - Created: #{admin.created_at.strftime('%B %d, %Y')}"
      end
      puts "=" * 50
      puts "Total: #{admins.count} admin(s)"
    end
  end
end
