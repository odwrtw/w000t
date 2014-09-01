# w000ts Controller
class W000tsController < ApplicationController
  before_action :set_w000t, only: [:show, :edit, :update, :destroy, :redirect]
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

  # GET /w000ts/1/edit
  def edit
  end

  # POST /w000ts
  # POST /w000ts.json
  def create
    @w000t = W000t.new(w000t_params)
    @w000t.user = current_user if user_signed_in?
    @w000t.shorten_url(w000t_params[:long_url])

    if @w000t.save
      # If it's a success, we return directly the new shortened url for
      # easy parsing
      render json: request.base_url + '/' + @w000t.short_url, status: :created
    else
      render json: @w000t.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /w000ts/1
  # PATCH/PUT /w000ts/1.json
  def update
    respond_to do |format|
      if @w000t.update(w000t_params)
        format.html do
          redirect_to @w000t,
                      notice: 'W000t was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @w000t }
      else
        format.html { render :edit }
        format.json do
          render json: @w000t.errors,
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /w000ts/1
  # DELETE /w000ts/1.json
  def destroy
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
    unless user_signed_in?
      redirect_to new_user_session_path
      return
    end

    @w000ts = W000t.where(user_id: current_user.id)
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
    render json: request.base_url + '/' + w000t.short_url if w000t
  end
end
