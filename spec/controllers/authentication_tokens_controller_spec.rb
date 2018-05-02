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

  before(:each) do
    request.env["HTTP_REFERER"] = 'where_i_came_from'
  end

  it 'should get index' do
    get :index, params: { user_pseudo: @user.pseudo }
    assert_response :success
    expect(assigns(:authentication_tokens)).not_to be_nil
  end

  it 'should get new' do
    get :new, params: { user_pseudo: @user.pseudo }
    assert_response :success
  end

  it 'should get edit' do
    get :edit, params: { user_pseudo: @user.pseudo, id: @authentication_token.id }
    assert_response :success
  end

  it 'should create authentication_token' do
    expect{
      post :create,
           params: {
             user_pseudo: @user.pseudo,
             authentication_token: { name: @authentication_token.name }
           }
    }.to change { AuthenticationToken.count }.by(1)

    assert_redirected_to user_authentication_tokens_path
  end

  it 'should update authentication_token' do
    @user_token = FactoryGirl.create(
      :authentication_token,
      user: @user,
      name: 'test_token'
    )
    patch :update,
          params: {
            id: @user_token.id,
            user_pseudo: @user.pseudo,
            authentication_token: { name: 'plop' }
          }

    @t = AuthenticationToken.find(@user_token.id)
    assert_equal @t.name, 'plop'
    assert_redirected_to user_authentication_tokens_path
  end

  it 'should not update as anonymous user' do
    patch :update,
          params: {
            id: @authentication_token.id,
            user_pseudo: @user.pseudo,
            authentication_token: { name: 'plop' }
          }
    expect(response).to redirect_to('where_i_came_from')
  end

  it 'should destroy authentication_token' do
    expect{
      delete :destroy,
             params: {
               user_pseudo: @user.pseudo,
               id: @authentication_token
             }
    }.to change { AuthenticationToken.count }.by(-1)

    assert_redirected_to user_authentication_tokens_path
  end
end
