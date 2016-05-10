require 'spec_helper'

describe "W000ts" do
  # let(:user) { Factory(:user) }
  #
  before(:all) do
    # puts "#{W000t.all.inspect}"
  end

  it 'should hash a long url with no user' do
    w000tTest = FactoryGirl.create(:w000t)
    # assert_equal '738ddf35b3', w000tTest.short_url
    assert_equal '64a1f36deb', w000tTest.short_url

    # user.send_password_reset
    # last_token = user.password_reset_token
    # user.send_password_reset
    # user.password_reset_token.should_not eq(last_token)
  end
end
