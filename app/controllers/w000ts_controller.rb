# w000ts Controller
class W000tsController < ApplicationController
  before_action :set_w000t, only: [:show, :edit, :destroy, :redirect]
  before_action :check_w000t, only: [:create]

  # GET /w000ts
  # GET /w000ts.json
  def index
    @w000ts = W000t.all
  end

  # GET /w000ts/1
  # GET /w000ts/1.json
  def show
  end

  # GET /w000ts/new
  def new
    @w000t = W000t.new
  end

  # POST /w000ts
  # POST /w000ts.json
  def create
    @w000t = W000t.new(w000t_params)
    @w000t.user = current_user if user_signed_in?

    if @w000t.save
      # If it's a success, we return directly the new shortened url for
      # easy parsing
      respond_to do |format|
        format.json do
          render json: @w000t.full_shortened_url(request.base_url),
                 status: :created
        end
        format.js { render :create, locals: { w000t: @w000t } }
      end
    else
      respond_to do |format|
        format.json do
          render json: @w000t.errors, status: :unprocessable_entity
        end
        format.js { @w000t }
      end
    end
  end

  # DELETE /w000ts/1
  # DELETE /w000ts/1.json
  # Only the w000t creator can delete is own w000t, for public w000ts, no
  # deletion for now
  def destroy
    # Only allow signed in users
    unless user_signed_in?
      return redirect_to new_user_session_url,
                         notice: 'You must login fisrt'
    end

    # Check user right
    unless current_user.w000ts.find_by(short_url: @w000t.short_url)
      return redirect_to w000ts_url, flash: {
        alert: 'You can not delete this w000t, only the owner can'
      }
    end

    @w000t.destroy
    respond_to do |format|
      format.html do
        redirect_to w000ts_url,
                    notice: 'W000t was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  def redirect
    @w000t.inc(number_of_click: 1)
    redirect_to @w000t.long_url
  end

  def my_index
    return redirect_to new_user_session_path unless user_signed_in?
    @w000ts = current_user.w000ts
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_w000t
    @w000t = W000t.find_by(short_url: params[:short_url])
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def w000t_params
    params.require(:w000t).permit(:long_url)
  end

  #
  def check_w000t
    w000t = W000t.find_by(long_url: w000t_params[:long_url])
    return unless w000t
    respond_to do |format|
      format.json do
        render json: w000t.full_shortened_url(request.base_url),
               status: :created
      end
      format.js { render :create, locals: { w000t: w000t } }
    end
  end
end
