# Migration to add image to the cloud
class MigrateToTheCloud < Mongoid::Migration
  def self.up
    cpt_upload = 0
    say_with_time('Creating task to upload in the cloud') do
      W000t.all.each do |w|
        w.create_task
        say "Task for #{w.url_info.url} created"
        cpt_upload += 1
      end
    end
    say " -> #{cpt_upload} w000t tasks created"
  end

  def self.down
    say_with_time('Deleting cloud_image') do
      W000t.all.each do |w|
        w.url_info.remove_cloud_image
        say "#{w.url_info.url} cloud_image removed"
      end
    end
  end
end
