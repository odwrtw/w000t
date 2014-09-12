class AdminController < ApplicationController
  before_action :authenticate_user!, :check_admin

  def dashboard
  end

  def check_all_w000ts
    W000t.all.each { |w| UrlLifeChecker.perform_async(w.long_url) }
    render :json => { status:'ok'}
  end

  private

  def check_admin
    redirect_to root_path unless current_user.admin?
  end
end
