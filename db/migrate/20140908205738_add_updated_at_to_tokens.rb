# Migration to add updated_at and created_at informations to Tokens
class AddUpdatedAtToTokens < Mongoid::Migration
  def self.up
    say_with_time('Changing created_at and updated_at') do
      # Get all the tokens that have updated_at to nil
      token_list = AuthenticationToken.where(updated_at: nil)

      token_list.each do |token|
        # Set the updated_at to now by touching it
        # Owww, touchMyTralala
        token[:created_at] = Time.now
        token.save
        say "#{token.id} was updated"
      end
    end
  end

  def self.down
  end
end
