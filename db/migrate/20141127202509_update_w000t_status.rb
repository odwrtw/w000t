class UpdateW000tStatus < Mongoid::Migration
  def self.up
    say_with_time('Adding status to w000ts') do
      W000t.all.each do |w|
        w.status = :public
        w.save
      end
    end
  end

  def self.down
  end
end
