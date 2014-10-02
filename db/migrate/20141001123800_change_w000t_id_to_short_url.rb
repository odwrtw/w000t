# Change all the w000t ids
class ChangeW000tIdToShortUrl < Mongoid::Migration
  def self.up
    cpt_destroy = 0
    say_with_time('Removing crap') do
      # Get all the duplicated w000ts
      @duplicated_w000ts = W000t.collection.aggregate([
        {
          '$group' => {
            '_id' => '$short_url',
            dup_w000ts: { '$addToSet' => '$_id' },
            count: { '$sum' => 1 }
          }
        },
        {
          '$match' => {
            count: { '$gt' => 1 }
          }
        }
      ]).map { |el| el[:dup_w000ts] }
      @duplicated_w000ts.flatten!

      @duplicated_w000ts.each do |id|
        W000t.where(short_url: id).each do |w|
          next unless w
          w.destroy
          say "#{w.short_url} destroyed"
          cpt_destroy += 1
        end
      end
      say " -> #{cpt_destroy} w000ts destroyed"
    end

    cpt_update = 0
    say_with_time('Changing id of w000t') do
      W000t.all.each do |w|
        # Clone this w000t
        clone = w.clone
        clone._id = w.short_url
        say "#{clone.short_url} updated"
        w.destroy
        clone.save
        cpt_update += 1
      end
    end
    say " -> #{cpt_update} w000ts updated"
  end

  def self.down
  end
end
