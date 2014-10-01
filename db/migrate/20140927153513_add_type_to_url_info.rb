# Add type to UrlInfo
class AddTypeToUrlInfo < Mongoid::Migration
  def self.up
    say_with_time('Adding type to UrlInfo') do
      UrlInfo.all.each do |u|
        u.type = nil
        u.save
        say "#{u.url} was updated with type '#{u.type}'"
      end
    end
  end

  def self.down
    say_with_time('Removing type from UrlInfo') do
      UrlInfo.all.each do |u|
        u.unset(:type)
        u.save
        say "#{u.url} was updated"
      end
    end
  end
end
