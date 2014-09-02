require 'test_helper'

class W000tTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  require 'digest/sha1'

  # Run before each test
  setup do
    User.all.destroy
    W000t.all.destroy

    # Known values
    @long_url = 'http://www.google.com'
    @short_url_without_user= '738ddf35b3'
    @short_url_with_user= '00e7901bd2'
  end

  test "should hash a long url with no user" do
    @w000t = FactoryGirl.create(:w000t, long_url: @long_url)
    assert_equal @short_url_without_user, @w000t.short_url
  end

  test "should hash a long url with user greg" do
    @greg = FactoryGirl.create(:user, pseudo: 'greg', email: 'greg@odwrtw.com')
    @w000t = FactoryGirl.build(:w000t, long_url: @long_url)
    @w000t.user = @greg
    @w000t.save
    assert_equal @short_url_with_user, @w000t.short_url
  end

  # TODO move this function to the lib folder so it can be used in the tests
  # too
  def hash_and_truncate(input_string)
    truncate(Digest::SHA1.hexdigest(input_string), length: 10, omission: '')
  end

end
