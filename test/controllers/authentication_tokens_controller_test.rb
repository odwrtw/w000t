require 'test_helper'

# AuthenticationToken
class AuthenticationTokensControllerTest < ActionController::TestCase
  setup do
    User.all.destroy
    AuthenticationToken.all.destroy

    @user = FactoryGirl.create(:user)
    @authentication_token = FactoryGirl.create(:authentication_token)
    sign_in @user

    request.env['HTTP_REFERER'] = 'previous_page'
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

  test 'should get edit' do
    get :edit, user_id: @user.id, id: @authentication_token.id
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

  test 'should update authentication_token' do
    @user_token = FactoryGirl.create(
      :authentication_token,
      user: @user,
      name: 'test_token'
    )
    patch :update,
          id: @user_token.id,
          user_id: @user.id,
          authentication_token: { name: 'plop' }

    @t = AuthenticationToken.find(@user_token.id)
    assert_equal @t.name, 'plop'
    assert_redirected_to user_authentication_tokens_path
  end

  test 'should not update as anonymous user' do
    patch :update,
          id: @authentication_token.id,
          user_id: @user.id,
          authentication_token: { name: 'plop' }
    assert_redirected_to 'previous_page'
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
