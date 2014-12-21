# User dashboard controller
class UserDashboardController < ApplicationController
  include W000tStatistics

  before_action :authenticate_user!, :set_user

  # GET /users/:user_pseudo/dashboard
  def show
    @total_w000t_number = @user.w000ts.count
    @w000t_top_ten = w000t_top_ten(@user)
    @w000t_by_day = w000t_by_day(@user)
    @w000t_count_by_status = w000t_count_by_status(@user)
    @w000t_count_by_type = w000t_count_by_type(@user)
  end

  private

  def set_user
    return redirect_to new_user_session_path unless user_signed_in?
    @user = current_user
    # Don't allow the wrong user in
    unless @user.pseudo == params[:user_pseudo]
      fail AbstractController::ActionNotFound
    end
  end
end
