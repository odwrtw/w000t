# AdminController
class AdminController < ApplicationController
  before_action :authenticate_user!, :check_admin

  def dashboard
    @total_w000t_number = W000t.all.count
    @total_user_number = User.all.count
    @total_url_number = User.all.count

    # User info
    @user_data = {}
    User.all.each do |user|
      @user_data[user.pseudo] = user.attributes
      @user_data[user.pseudo][:w000t_counts] = user.w000ts.count
    end
  end

  def check_all_w000ts
    W000t.all.each { |w| UrlLifeChecker.perform_async(w.long_url) }
    render json: { status: 'ok' }
  end

  def check_url
    url = admin_params[:long_url]
    return render json: { error: 'No url to check' } unless url
    UrlLifeChecker.perform_async(url)
    render json: { status: 'ok' }
  end

  private

  def check_admin
    redirect_to root_path unless current_user.admin?
  end

  def admin_params
    params.require(:admin).permit(:long_url)
  end
end
