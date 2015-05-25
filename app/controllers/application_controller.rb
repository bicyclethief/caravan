class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  helper_method :current_user_profile
  helper_method :authenticate_user!
  helper_method :set_return_point
  helper_method :return_point
  helper_method :format_date
  helper_method :bootstrap_class_for
  helper_method :bounce_guest

  def index
    render layout: 'landing-page'
  end

  def current_user
    User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_user_profile
    user_path current_user
  end

  def authenticate_user!(return_point = request.url)
    unless current_user
      set_return_point(return_point)
      redirect_to signin_path
    end
  end

  def set_return_point(path, overwrite = false)
    if overwrite || session[:return_point].blank?
      session[:return_point] = path
    end
  end

  def return_point
    session[:return_point] || root_path
  end

  def format_date(input_date)
    output_date = "#{input_date.strftime('%b %d, %Y')}"
  end

  def bootstrap_class_for(flash_type)
    case flash_type
      when "success"
        "alert-success"   # Green
      when "error"
        "alert-danger"    # Red
      when "alert"
        "alert-warning"   # Yellow
      when "notice"
        "alert-info"      # Blue
      else
        flash_type.to_s
    end
  end

  def bounce_guest(parcel)
    redirect_to profile_path if parcel.sender != current_user
  end

end
