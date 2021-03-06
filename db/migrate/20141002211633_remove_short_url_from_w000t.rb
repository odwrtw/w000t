# Delete short_url from w000ts
class RemoveShortUrlFromW000t < Mongoid::Migration
  def self.up
    say_with_time('Removing short_url field') do
      # Get all the w000ts and remove the short_url

      W000t.all.update_all('$unset' => { 'short_url' => 1 })
    end
  end

  def self.down
  end
end
