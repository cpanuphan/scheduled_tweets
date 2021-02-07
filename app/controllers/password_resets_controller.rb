class PasswordResetsController < ApplicationController

  def new

  end

  def create
    @user = User.find_by(email: params[:email])

    if @user.present?
      # send email
      PasswordMailer.with(user: @user).reset.deliver_later
    end
    redirect_to root_path, notice: "If an account with the email was found, we have sent a link to reset your password."
  end

  def edit
    @user = User.find_signed!(params[:token], purpose: "password_reset") 
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to sign_in_path, alert: "Your token has expired, Please try again later."
  end
  
  def update
    @user = User.find_signed!(params[:token], purpose: "password_reset") 
    if @user.update(user_params)
      redirect_to sign_in_path, notice: "Your password was reset successfully, Please sign in."
    else
      render 'edit'
    end
  end

  private
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
  
end