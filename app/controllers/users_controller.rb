class UsersController < ApplicationController
  # before_action :authenticate_user!
  
  # def show
  #   Rails.logger.debug "Parameters: #{params.inspect}"
  #   @user = User.find(params[:id])
  # end

  # def create
  #   @user = User.new(user_params)
  #   if @user.save
  #     redirect_to @user, notice: "ユーザーが作成されました。"
  #   else
  #     # エラーメッセージを取得
  #     @error_messages = @user.errors.full_messages
  #     render :new
  #   end
  # end

  private

  # def user_params
  #   # ストロングパラメータで、名前とメールを受け取ることができるように設定しておく。
  #   params.require(:user).permit(:name, :email)
  # end
end
