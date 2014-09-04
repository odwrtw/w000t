# AuthenticationTokensController
class AuthenticationTokensController < ApplicationController
  before_action :set_authentication_token,
                only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, :set_user

  # GET /authentication_tokens
  # GET /authentication_tokens.json
  def index
    user = current_user if user_signed_in?
    user = @token_user if @token_user
    return redirect_to new_user_session unless user
    @authentication_tokens = user.authentication_tokens
  end

  # GET /authentication_tokens/1
  # GET /authentication_tokens/1.json
  def show
  end

  # GET /authentication_tokens/new
  def new
    @authentication_token = AuthenticationToken.new
  end

  # GET /authentication_tokens/1/edit
  def edit
  end

  # POST /authentication_tokens
  # POST /authentication_tokens.json
  def create
    @authentication_token = AuthenticationToken.new(authentication_token_params)
    @authentication_token.user = current_user

    respond_to do |format|
      if @authentication_token.save
        format.html do
          redirect_to user_authentication_tokens_url,
                      notice: 'Authentication token was successfully created.'
        end
        format.json do
          render :show, status: :created, location: @authentication_token
        end
      else
        format.html { render :new }
        format.json do
          render json: @authentication_token.errors,
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /authentication_tokens/1
  # DELETE /authentication_tokens/1.json
  def destroy
    @authentication_token.destroy
    respond_to do |format|
      format.html do
        redirect_to user_authentication_tokens_url,
                    notice: 'Authentication token was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = current_user
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_authentication_token
    @authentication_token = AuthenticationToken.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def authentication_token_params
    params.require(:authentication_token).permit(:name)
  end
end
