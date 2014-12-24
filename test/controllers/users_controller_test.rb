require 'test_helper'

# User controller class
class UsersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user, pseudo: 'bob')
    @admin_user = FactoryGirl.create(
      :user, pseudo: 'admin', email: 'email@admin.com', admin: true
    )
  end

  test 'should not get user infos as non admin user using json format' do
    sign_in @user
    get :show, user_pseudo: 'bob', format: :json
    assert_response :not_found
  end

  test 'should get user infos as admin user using json format' do
    sign_in @admin_user
    get :show, user_pseudo: 'bob', format: :json
    assert_response :success
    json_expected_keys %w(
      id email pseudo admin created_at sign_in_count last_sign_in_at
      current_sign_in_at last_sign_in_ip current_sign_in_ip
    )
  end

  test 'should not get user list as non admin user using json format' do
    sign_in @user
    get :index, format: :json
    assert_response :not_found
  end

  test 'should get user list as admin using json format' do
    sign_in @admin_user
    get :index, format: :json
    assert_response :success
  end
end
