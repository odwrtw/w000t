require 'test_helper'

# AuthenticationToken Model unittest
class AuthenticationTokenTest < ActiveSupport::TestCase
  setup do
    User.all.destroy
    W000t.all.destroy
    AuthenticationToken.all.destroy

    # Known values
    @user = FactoryGirl.create(:user)
  end

  def new_token(user, name)
    FactoryGirl.build(
      :authentication_token,
      user: user,
      name: name
    )
  end

  test 'should not update authentication_token with same name' do
    first_token = new_token(@user, 'test_token')
    assert first_token.valid?, 'Simple token should be valid'
    first_token.save

    second_token = new_token(@user, 'test_token')
    assert second_token.invalid?, 'Duplicate token should not be valid'
  end

  test 'should be valid' do
    @auth_token = new_token(@user, 'test_valid')
    assert @auth_token.valid?
    @auth_token.save
  end
end
