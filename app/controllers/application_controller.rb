class ApplicationController < ActionController::API
  attr_reader :current_user

  def render_json(json)
    render json: json, status: :ok
  end

  def render_problem(error_code, error_message)
    model_name = params[:controller].split('/').last
    render problem: {
      title: I18n.t("action.#{model_name}.#{params[:action]}"),
      error_code: error_code,
      error_message: error_message
    }, status: :bad_request
  end

  # rescue ActiveRecord::RecordNotFound
  rescue_from ActiveRecord::RecordNotFound do |_exception|
    model_name = params[:controller].split('/').last
    render problem: {
      title: I18n.t("action.#{model_name}.#{params[:action]}"),
      error_code: 'UAM_000001',
      error_message: [
        I18n.t("activerecord.errors.messages.record_not_found", model_name: I18n.t("activerecord.models.#{model_name}"))
      ]
    }, status: :not_found
  end

  protected

  def authenticate_request!
    unless user_id_in_token?
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
      return
    end
    @current_user = User.find(auth_token[:user_id])
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  private

  def http_token
    @http_token ||= (request.headers['Authorization'].split.last if request.headers['Authorization'].present?)
  end

  def auth_token
    @auth_token ||= JsonWebToken.decode(http_token)
  end

  def user_id_in_token?
    http_token && auth_token && auth_token[:user_id].to_i
  end
end
