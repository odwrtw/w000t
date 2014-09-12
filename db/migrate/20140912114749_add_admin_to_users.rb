class AddAdminToUsers < Mongoid::Migration
  def self.up
    say_with_time('Adding admin to users') do
      User.all.each do |user|
        user.admin = false
        user.save
        say "#{user.pseudo} updated"
      end
    end
  end

  def self.down
    say_with_time('Removing admin to users') do
      User.all.each do |user|
        user.unset(:admin)
        user.save
        say "#{user.pseudo} updated"
      end
    end
  end
end
