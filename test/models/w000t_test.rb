require 'test_helper'

# W000t Model unittest
class W000tTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  require 'digest/sha1'

  # Run before each test
  setup do
    User.all.destroy
    W000t.all.destroy

    # Known values
    @long_url = 'http://www.google.com'
    @short_url_without_user = '738ddf35b3'
    @short_url_with_user = '00e7901bd2' # Pseudo greg
  end

  test 'should hash a long url with no user' do
    @w000t = FactoryGirl.create(:w000t, long_url: @long_url)
    assert_equal @short_url_without_user, @w000t.short_url
  end

  test 'should hash a long url with user greg' do
    @greg = FactoryGirl.create(:user, pseudo: 'greg', email: 'greg@odwrtw.com')
    @w000t = FactoryGirl.build(:w000t, long_url: @long_url)
    @w000t.user = @greg
    @w000t.save
    assert_equal @short_url_with_user, @w000t.short_url
  end

  test 'should not have an empty long_url' do
    @w000t = W000t.new
    assert @w000t.invalid?, 'An empty w000t should not be valid'
    assert @w000t.errors[:long_url].any?
  end

  test 'should not have an invalid long_url' do
    @w000t = W000t.new(long_url: 'http://')
    assert @w000t.invalid?, 'An empty w000t should not be valid'
    assert @w000t.errors[:long_url].any?
  end

  test 'should be valid' do
    @w000t = W000t.new(long_url: @long_url)
    assert @w000t.valid?
  end

  test 'should be invalid whitout http prefix' do
    @w000t = W000t.new(long_url: 'google.com')
    assert @w000t.invalid?
    assert @w000t.errors[:long_url].any?
  end
end
