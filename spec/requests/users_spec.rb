require "rails_helper"
require "spec_helper"

describe "Users requests", :type => :request do
  before do
    User.delete_all
    W000t.delete_all
    AuthenticationToken.destroy_all
    Sidekiq::Worker.clear_all

    @user = FactoryBot.create(:user, pseudo: 'bob')
    @admin_user = FactoryBot.create(
      :user, pseudo: 'admin', email: 'email@admin.com', admin: true
    )
  end

  def sign_in(user)
    login_as(user, scope: :user)
  end

  it 'should get user infos as admin user using json format' do
    sign_in @admin_user
    get "/users/bob", as: :json
    assert_response :success
    json_expected_keys %w(
      id email pseudo admin created_at sign_in_count last_sign_in_at
      current_sign_in_at last_sign_in_ip current_sign_in_ip
    )
  end
end
