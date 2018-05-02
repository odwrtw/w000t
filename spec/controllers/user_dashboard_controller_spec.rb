require 'spec_helper'

# User dashboard controller tests
describe UserDashboardController do
  before do
    User.delete_all
    W000t.delete_all
    AuthenticationToken.destroy_all
    FakeWeb.clean_registry
    Sidekiq::Worker.clear_all

    @user_greg = FactoryGirl.create(
      :user, pseudo: 'greg', email: 'greg@w000t.me'
    )
    @user_pouulet = FactoryGirl.create(
      :user, pseudo: 'pouulet', email: 'pouulet@w000t.me'
    )
  end

  it 'should be redirected if not logged' do
    get :show, params: { user_pseudo: 'greg' }
    assert_redirected_to new_user_session_path
  end

  it 'should get user\'s dashboard' do
    sign_in @user_pouulet
    get :show, params: { user_pseudo: @user_pouulet.pseudo }
    assert_response :success
  end

  it 'should get a 404 trying to access another user\'s dashboard' do
    sign_in @user_pouulet
    get :show, params: { user_pseudo: @user_greg.pseudo }
    assert_response :not_found
  end
end
