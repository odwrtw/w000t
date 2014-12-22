# Remove duplicated url <=> user association
class RemoveDuplicatedUrlByUser < Mongoid::Migration
  def self.up
    cpt_destroy = 0
    say_with_time('Removing crap') do
      # Get all the duplicated w000ts
      W000t.collection.aggregate([
        {
          '$group' => {
            '_id' => {
              'url_info.url' => '$url_info.url',
              'user_id' => '$user_id'
            },
            ids_to_remove: { '$addToSet' => '$_id' },
            count: { '$sum' => 1 }
          }
        },
        {
          '$match' => {
            count: { '$gt' => 1 }
          }
        }
      ]).each do |data|
        say "Deleting w000ts linked to url #{data[:_id]['url_info.url']}"
        say "#{data[:ids_to_remove].inspect}"
        data[:ids_to_remove].each do |id|
          say "Deleting w000t with id : #{id}"
          w = W000t.find(id)
          next unless w
          w.destroy
          say "#{w.short_url} destroyed"
          cpt_destroy += 1
        end
      end
      say " -> #{cpt_destroy} w000ts destroyed"
    end
  end

  def self.down
  end
end
