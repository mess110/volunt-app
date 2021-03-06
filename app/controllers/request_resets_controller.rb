class RequestResetsController < ApplicationController
  include SslConfig
  force_ssl only: [:show, :create], if: :ssl_configured?
  layout 'static'

  def show
    @request_reset_presenter = RequestResetPresenter.new
  end

  def create
    @request_reset_presenter = RequestResetPresenter.new params_permit
    if @request_reset_presenter.invalid?
      render action: :show, status: :conflict
    else
      user = User.where(email: @request_reset_presenter.email).first
      if user.nil?
        # if the user doesn't exist but a profile claims this email, 
        # create an user on-the-fly. The email cannot login yet until
        # it prooves email ownership via the link
        profile = Profile.for_email @request_reset_presenter.email
        if profile
          user = User.create(email: @request_reset_presenter.email)
        end
      end
      unless user.nil?
        # rescue all exception to prevent leakage of account existance
        begin
          UserMailer.reset_password(user).deliver_now
        rescue Exception => e
          Rails.logger.error "Exception in RequestResetsController::create: #{e.class.name}:  #{e.message}"
        end
      end
      redirect_to login_path, notice: 'Am trimis un email cu instructiuni de resetare a parolei'
    end
  end

  private

  def params_permit
    params.fetch(:request_reset_presenter, {}).permit(:email)
  end
  
end


