# frozen_string_literal: true

# rubocop:disable Layout/OrderedMethods
class Api::V1::Admin::UsersController < Api::V1::BaseController
  before_action :require_admin!
  before_action :set_user, only: %i[show update destroy]

  def index
    users = User.order(:email).page(params[:page]).per(params[:per_page] || 20)
    users = users.where("email ILIKE ?", "%#{params[:search]}%") if params[:search].present?

    render json: {
      users: UserBlueprint.render_as_hash(users),
      meta: pagination_meta(users)
    }
  end

  def show
    render json: { user: UserBlueprint.render_as_hash(@user) }
  end

  def create
    user = User.new(user_params)
    user.password = SecureRandom.hex(12) if user_params[:password].blank?

    if user.save
      render json: { user: UserBlueprint.render_as_hash(user) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_update_params)
      render json: { user: UserBlueprint.render_as_hash(@user) }
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      render json: { error: "Cannot delete your own account." }, status: :unprocessable_entity
    else
      @user.destroy
      head :no_content
    end
  end

  def deactivate
    user = User.find(params[:id])
    user.update!(active: false)
    render json: { user: UserBlueprint.render_as_hash(user) }
  end

  def reactivate
    user = User.find(params[:id])
    user.update!(active: true)
    render json: { user: UserBlueprint.render_as_hash(user) }
  end

  private

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      per_page: collection.limit_value,
      total_count: collection.total_count,
      total_pages: collection.total_pages
    }
  end

  def require_admin!
    authorize_role!(:admin)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:barangay_name, :email, :full_name, :password, :role)
  end

  def user_update_params
    params.require(:user).permit(:active, :barangay_name, :email, :full_name, :role)
  end
end
# rubocop:enable Layout/OrderedMethods
