require 'spec_helper'

# AuthenticationToken
describe AuthenticationTokensController do
  before do
    User.delete_all
    W000t.delete_all
    AuthenticationToken.destroy_all
    FakeWeb.clean_registry
    Sidekiq::Worker.clear_all

    @user = FactoryGirl.create(:user)
    @authentication_token = FactoryGirl.create(:authentication_token)
    sign_in @user
  end

  it 'should get index' do
    get :index, user_pseudo: @user.pseudo
    assert_response :success
    assert_not_nil assigns(:authentication_tokens)
  end

  it 'should get new' do
    get :new, user_pseudo: @user.pseudo
    assert_response :success
  end

  it 'should get edit' do
    get :edit, user_pseudo: @user.pseudo, id: @authentication_token.id
    assert_response :success
  end

  it 'should create authentication_token' do
    assert_difference('AuthenticationToken.count') do
      post :create,
           user_pseudo: @user.pseudo,
           authentication_token: { name: @authentication_token.name }
    end

    assert_redirected_to user_authentication_tokens_path
  end

  it 'should update authentication_token' do
    @user_token = FactoryGirl.create(
      :authentication_token,
      user: @user,
      name: 'test_token'
    )
    patch :update,
          id: @user_token.id,
          user_pseudo: @user.pseudo,
          authentication_token: { name: 'plop' }

    @t = AuthenticationToken.find(@user_token.id)
    assert_equal @t.name, 'plop'
    assert_redirected_to user_authentication_tokens_path
  end

  it 'should not update as anonymous user' do
    patch :update,
          id: @authentication_token.id,
          user_pseudo: @user.pseudo,
          authentication_token: { name: 'plop' }
    assert_redirected_to 'previous_page'
  end

  it 'should destroy authentication_token' do
    assert_difference('AuthenticationToken.count', -1) do
      delete :destroy,
             user_pseudo: @user.pseudo,
             id: @authentication_token
    end

    assert_redirected_to user_authentication_tokens_path
  end
end
