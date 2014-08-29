require 'test_helper'

# UsersController tests
class UsersControllerTest < ActionController::TestCase
  setup do
    User.all.destroy
    W000t.all.destroy

    @user = FactoryGirl.create(:user)
  end

  test 'should get create as json' do
    post :create, user: {
      name: 'Tutu',
      email: 'tutu@example.com'
    }, format: :json
    assert_response :success
  end

  test 'should destroy as json' do
    post :destroy, id: @user.id, format: :json
    assert_response :success
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should get show' do
    get :show, id: @user.id
    assert_response :success
  end
end
