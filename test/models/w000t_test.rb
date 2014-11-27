require 'test_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

# W000t Model unittest
class W000tTest < ActiveSupport::TestCase
  include ActionView::Helpers::TextHelper
  require 'digest/sha1'

  # Run before each test
  setup do
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
    assert @w000t.url_info.invalid?, 'An empty w000t should not be valid'
    assert @w000t.url_info.errors[:url].any?
  end

  test 'should not have an invalid long_url' do
    @w000t = W000t.new(long_url: 'http://')
    assert @w000t.url_info.invalid?, 'An empty w000t should not be valid'
    assert @w000t.url_info.errors[:url].any?
  end

  test 'should be valid' do
    @w000t = W000t.new(long_url: @long_url)
    assert @w000t.valid?
  end

  test 'should be valid whitout http prefix and should have http prefix' do
    @w000t = W000t.create(long_url: 'google.com')
    assert @w000t.url_info.valid?, 'w000t without http prefix is invalid'
    assert @w000t.url_info.url =~ /^http/,
           'w000t without http prefix does not have http prefix'
  end

  test 'shoud create a life checker task when creating a new w000t' do
    assert_difference 'UrlLifeChecker.jobs.size' do
      @w000t = W000t.create(long_url: @long_url)
    end
  end

  test 'shoud have a valid status' do
    W000t::STATUS.each do |s|
      @w000t = FactoryGirl.build(:w000t, long_url: @long_url, status: s)
      assert @w000t.valid?, "w000t should be valid with this staus : #{s}"
    end
  end

  test 'shoud not be valid with a wrong status' do
    %i( test yo mama ).each do |s|
      @w000t = FactoryGirl.build(:w000t, long_url: @long_url, status: s)
      assert @w000t.invalid?, "invalid w000t status #{s}"
    end
  end
end
