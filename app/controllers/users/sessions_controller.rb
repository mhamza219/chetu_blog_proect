# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  def create
    # byebug
    # 1. Find the user first without signing them in
    self.resource = resource_class.find_by(email: params[:user][:email])

    # 2. Perform your manual check
    if self.resource && manual_security_check_fails?
      # If the check fails, redirect or show an error
      set_flash_message!(:alert, :magic_error_message) # Define this in devise.en.yml
      return redirect_to new_user_session_path
    end

    # 3. If manual check passes, let Devise handle the standard password/lock check
    super
  end

  private

  def manual_security_check_fails?
    # Your custom logic here
    # Example: block specific email domains or time-based restrictions
    # return true if you want to BLOCK the login
    false
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
