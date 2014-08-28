# w000ts Controller
class W000tsController < ApplicationController
  before_action :set_w000t, only: [:show, :edit, :update, :destroy, :redirect]

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
    # if @user
    #   @w000t = @user.w000ts.build(w000t_params)
    # else
    #   @w000t = W000t.new(w000t_params)
    # end
    @w000t = W000t.new(w000t_params)

    # Search for already added w000t
    if w000t = W000t.find_by(long_url: w000t_params[:long_url])
      logger.debug w000t.inspect
      render json: request.base_url + '/' + w000t.short_url
      return
    end

    logger.debug "Going to w000t this shit down! #{w000t_params[:long_url]}"

    @w000t.shorten_url(w000t_params[:long_url])

    logger.debug "It's been w000ted to #{@w000t.short_url}"

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
        format.html { redirect_to @w000t, notice: 'W000t was successfully updated.' }
        format.json { render :show, status: :ok, location: @w000t }
      else
        format.html { render :edit }
        format.json { render json: @w000t.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /w000ts/1
  # DELETE /w000ts/1.json
  def destroy
    @w000t.destroy
    respond_to do |format|
      format.html { redirect_to w000ts_url, notice: 'W000t was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def redirect
    redirect_to @w000t.long_url
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_w000t
    @w000t = W000t.find_by(short_url: params[:short_url])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def w000t_params
    params.require(:w000t).permit(:long_url)
  end
end
