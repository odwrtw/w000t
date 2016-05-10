# User authentication
module W000thentication
  extend ActiveSupport::Concern

  # Set user no redirection will be done
  def w000thenticate
    check_token
  end

  # Set user and redirect if the user is not found
  def w000thenticate!
    check_token
    authenticate_user!
  end

  # Set user and redirect if the user is not found
  def w000thenticate_admin!
    check_token
    authenticate_user!
    raise AbstractController::ActionNotFound unless current_user.admin?
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
    # Update the updated_at because inc doesn't do it
    token.set(updated_at: Time.now.getlocal)

    # Sign in
    sign_in token.user
  end
end
