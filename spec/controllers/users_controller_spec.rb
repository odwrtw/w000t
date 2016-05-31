require 'spec_helper'

# User controller class
describe UsersController do
  before do
    User.delete_all
    W000t.delete_all
    AuthenticationToken.destroy_all
    FakeWeb.clean_registry
    Sidekiq::Worker.clear_all

    @user = FactoryGirl.create(:user, pseudo: 'bob')
    @admin_user = FactoryGirl.create(
      :user, pseudo: 'admin', email: 'email@admin.com', admin: true
    )
  end

  it 'should not get user infos as non admin user using json format' do
    sign_in @user
    get :show, user_pseudo: 'bob', format: :json
    assert_response :not_found
  end

  it 'should not get user list as non admin user using json format' do
    sign_in @user
    get :index, format: :json
    assert_response :not_found
  end

  it 'should get user list as admin using json format' do
    sign_in @admin_user
    get :index, format: :json
    assert_response :success
  end
end
