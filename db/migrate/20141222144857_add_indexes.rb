class AddIndexes < Mongoid::Migration
  def self.up
    say_with_time('Creating index') do
      Rake::Task['db:mongoid:create_indexes']
    end
  end

  def self.down
    say_with_time('Deleting index') do
      Rake::Task['db:mongoid:remove_indexes']
    end
  end
end
