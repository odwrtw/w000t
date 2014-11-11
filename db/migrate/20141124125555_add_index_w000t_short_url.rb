class AddIndexW000tShortUrl < Mongoid::Migration
  def self.up
    say_with_time('Creating index for w000ts on short_url') do
      Rake::Task['db:mongoid:create_indexes']
    end
  end

  def self.down
    say_with_time('Deleting index for w000ts on short_url') do
      Rake::Task['db:mongoid:remove_indexes']
    end
  end
end
