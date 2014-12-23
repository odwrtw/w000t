# w000ts Controller
class W000tsController < ApplicationController
  include W000thentication

  # Set w000t before w000t related actions
  before_action :set_w000t, only:
                  [:show, :edit, :update, :destroy, :redirect, :click]
  # Auth by token before show, the informations depends on the user rights
  before_action :w000thenticate, only: [:create, :show]
  # Actions where the user needs to be logged in
  before_action :w000thenticate!, only: [:destroy, :update, :edit, :my_index]
  # Check to performs before w000t creation
  before_action :prevent_w000tception, :check_w000t, only: [:create]
  # Set the user from the routes
  before_action :set_user, only: [:image_index]
  # Check the rights of the user on the w000t
  before_action :check_w000t_owner, only: [:update, :destroy]
  # Check if the type is allowed
  before_action :check_w000t_type_params, only: [:my_index]

  # GET /w000ts
  def index
    @w000ts = W000t.where(user: nil, status: :public)
                   .order_by(created_at: :desc)
                   .page(params[:page]).per(25)
  end

  # GET /w000ts/1
  def show
  end

  # GET /w000ts/new
  def new
    @w000t = W000t.new
  end

  # GET /w000ts/new
  def update
    if @w000t.update(w000t_update_params)
      respond_to do |format|
        format.js { render :update_w000t, locals: { w000t: @w000t } }
        format.html do
          redirect_to :back,
                      notice: 'W000t was successfully updated'
        end
      end
    else
      render_errors
    end
  end

  # POST /w000ts
  def create
    @w000t = W000t.new(w000t_params)
    @w000t.user = current_user if user_signed_in?

    if @w000t.save
      # If it's a success, we return directly the new shortened url for
      # easy parsing
      render_create_w000t
    else
      render_errors
    end
  end

  # DELETE /w000ts/1
  # Only the w000t creator can delete is own w000t, for public w000ts, no
  # deletion for now
  def destroy
    if @w000t.destroy
      respond_to do |format|
        format.html do
          redirect_to :back,
                      notice: 'W000t was successfully destroyed'
        end
        format.js { render :delete_w000t, locals: { w000t: @w000t } }
        format.json { head :no_content }
      end
    else
      render_errors
    end
  end

  # GET /:short_url
  def redirect
    @w000t.inc(number_of_click: 1)
    redirect_to @w000t.url_info_url
  end

  # GET /:short_url/click
  # Add a click to the count but do not redirect, used to diplay w000t preview
  def click
    @w000t.inc(number_of_click: 1)
    respond_to do |format|
      format.js { @w000t }
    end
  end

  # GET /w000t/me
  def my_index
    @w000ts = current_user.w000ts
    unless params[:tags].blank?
      @w000ts = @w000ts.tagged_with_all(params[:tags].split(',').map(&:strip))
      @tags = params[:tags]
    end
    if params[:type]
      @w000ts = @w000ts.by_type(params[:type])
                .order_by(created_at: :desc).page(params[:page]).per(25)
    else
      @w000ts = @w000ts.order_by(created_at: :desc)
                .page(params[:page]).per(25)
    end
  end

  # GET /w000ts/meme
  def my_image_index
    @w000ts = random_paginated_w000ts(current_user.w000ts.of_owner_wall)
  end

  # GET /users/:user_pseudo/wall
  def image_index
    @w000ts = random_paginated_w000ts(@user.w000ts.of_public_wall)
  end

  # GET /public/wall
  def public_wall
    @w000ts = random_paginated_w000ts(W000t.of_public_wall.limit(200))
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_w000t
    @w000t = W000t.find_by(short_url: params[:short_url])
    fail AbstractController::ActionNotFound unless @w000t
  end

  # Set user on image_index
  def set_user
    # Get user
    @user = User.find_by(pseudo: params[:user_pseudo])
    fail AbstractController::ActionNotFound unless @user
  end

  # Allowed params for w000t creation
  def w000t_params
    params.require(:w000t).permit(
      :long_url,
      :tags,
      :status,
      :upload_image
    )
  end

  # Allowed params for w000t update
  def w000t_update_params
    params.require(:w000t).permit(
      :tags,
      :status
    )
  end

  # Prevent from w000ting a w000t
  # If the w000t already exists, return it with a status 200 OK
  def prevent_w000tception
    # Check url format
    match = /\A#{request.base_url}\/(\w{10})\Z/.match(w000t_params[:long_url])
    return unless match

    # Check if the w000t already exists
    @w000t = W000t.find_by(_id: match[1])
    return unless @w000t

    # w000t already created, return status ok
    render_create_w000t(:ok)
  end

  # If there is already an existing w000t, return it
  def check_w000t
    # Don't need to check w000t if user is uploading an image
    return if w000t_params[:url_info_attributes]

    user_id = current_user ? current_user.id : nil
    user_id = @token_user.id if @token_user
    url = UrlInfo.prefixed_url(w000t_params[:long_url])
    @w000t = W000t.find_by(
      user_id: user_id,
      'url_info.url' => url
    )
    return unless @w000t

    # w000t already created, return status ok
    render_create_w000t(:ok)
  end

  # Check user right on w000t
  def check_w000t_owner
    action = params[:action]
    action = 'delete' if action.eql? 'destroy'
    unless current_user.w000ts.find_by(short_url: @w000t.short_url)
      return redirect_to :back, flash: {
        alert: "You can not #{action} this w000t, only the owner can"
      } unless current_user.admin?
    end
  end

  # Check if the given type is allowed
  def check_w000t_type_params
    return unless params[:type]
    unless TypableUrl::TYPES.include? params[:type].to_sym
      return redirect_to w000ts_me_path, flash: { alert: 'Invalid filter' }
    end
  end

  # Return an awesome random set of w000ts
  def random_paginated_w000ts(query)
    params[:seed] ||= Random.new_seed
    srand params[:seed].to_i
    Kaminari.paginate_array(query.shuffle).page(params[:page]).per(20)
  end

  # Render the w000t creation in any format
  def render_create_w000t(status = nil)
    status ||= :created
    w000t_url = @w000t.full_shortened_url(request.base_url)
    respond_to do |format|
      format.json { render :create, locals: { w000t: @w000t }, status: status }
      format.js   { render :create, locals: { w000t: @w000t } }
      format.html { redirect_to :back, notice: "W000t created #{w000t_url}" }
      format.text { render text: w000t_url }
    end
  end

  def render_errors
    respond_to do |format|
      format.json do
        render json: @w000t.errors, status: :unprocessable_entity
      end
      format.html { render action: :new }
    end
  end
end
