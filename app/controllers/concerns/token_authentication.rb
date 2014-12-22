# User authentication
module TokenAuthentication
  extend ActiveSupport::Concern

  # Set user no redirection will be done
  def authenticate_user_by_token
    check_token unless user_signed_in?
  end

  # Set user and redirect if the user is not found
  def authenticate_user_by_token!
    authenticate_user_by_token
    redirect_to new_user_session_path unless user_signed_in?
  end

  private

  # Check token from header or params
  # Increase token count
  def check_token
    input_token = request.headers['X-Auth-Token'] || params[:token]
    return unless input_token

    token = AuthenticationToken.find_by(token: input_token)
    return unless token

    # Count token usage
    token.inc(number_of_use: 1)

    # Sign in
    sign_in token.user
  end
end
