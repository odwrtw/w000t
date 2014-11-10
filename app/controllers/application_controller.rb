# ApplicationController
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, if: (proc do
    |c| c.request.format == 'application/json'
  end)

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Handle 404
  rescue_from AbstractController::ActionNotFound, with: :render_404

  protected

  def render_404
    respond_to do |format|
      format.html do
        render file: "#{Rails.root}/public/404",
               layout: 'application', status: :not_found
      end
      format.any  { head :not_found }
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :pseudo
    devise_parameter_sanitizer.for(:account_update) << :pseudo
  end
end
