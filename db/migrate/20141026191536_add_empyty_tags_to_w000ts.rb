class AddEmpytyTagsToW000ts < Mongoid::Migration
  def self.up
    say_with_time('Adding empty tags array to w000ts') do
      W000t.all.each do |w|
        w.tags_array = []
        w.save
      end
    end
  end

  def self.down
  end
end
