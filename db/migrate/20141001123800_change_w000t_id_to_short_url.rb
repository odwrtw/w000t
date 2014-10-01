# Change all the w000t ids
class ChangeW000tIdToShortUrl < Mongoid::Migration
  def self.up
    say_with_time('Removing crap') do
      %w(
        75526ac69 328c81739 cf1c1e58e d3b19b5a9 c0a140ed3 dba347405 4256c6ca5
      ).each do |id|
        W000t.where(short_url: id).each do |w|
          w && w.destroy
        end
      end
    end

    cpt = 0
    say_with_time('Changing id of w000t') do
      W000t.all.each do |w|
        # Clone this w000t
        clone = w.clone
        clone._id = w.short_url
        say "#{clone.short_url} updated"
        w.destroy
        clone.save
        cpt += 1
      end
    end
    say "#{cpt} w000ts updated"
  end

  def self.down
  end
end
