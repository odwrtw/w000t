require 'test_helper'

# AuthenticationToken
class AuthenticationTokensControllerTest < ActionController::TestCase
  setup do
    User.all.destroy
    AuthenticationToken.all.destroy

    @user = FactoryGirl.create(:user)
    @authentication_token = FactoryGirl.create(:authentication_token)
    sign_in @user
  end

  test 'should get index' do
    get :index, user_id: @user.id
    assert_response :success
    assert_not_nil assigns(:authentication_tokens)
  end

  test 'should get new' do
    get :new, user_id: @user.id
    assert_response :success
  end

  test 'should create authentication_token' do
    assert_difference('AuthenticationToken.count') do
      post :create,
           user_id: @user.id,
           authentication_token: { name: @authentication_token.name }
    end

    assert_redirected_to user_authentication_tokens_path
  end

  test 'should destroy authentication_token' do
    assert_difference('AuthenticationToken.count', -1) do
      delete :destroy,
             user_id: @user.id,
             id: @authentication_token
    end

    assert_redirected_to user_authentication_tokens_path
  end
end
