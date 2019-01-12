class UsersController < ApplicationController
  before_action :set_user, only: [:updateUser, :destroyUser]
  before_action :set_profile, only: [:updateProfile]

  def index
    if session[:username]
      @user = User.find_by(username: session[:username])
      if(@user.profile != nil)
        @profile = @user.profile
      else
        @profile = Profile.new
      end
    else
      redirect_to root_path
    end
  end

  def edit
    if session[:username]
      @user = User.find_by(username: session[:username])
      if(@user.profile != nil)
        @profile = @user.profile
      else
        @profile = Profile.new
      end
    else
      redirect_to root_path
    end
  end

  def signIn
  end

  def signUp
    @user = User.new
  end

  def createSession
    user = User.find_by(username: params[:session][:username], password: params[:session][:password])
    respond_to do |format|
      if user
          session[:user_id] = user.id
          session[:username] = user.username 
          format.html { redirect_to dashboard_path, notice: 'Sign in was successful.' }
      else
          format.html { redirect_to signin_path, notice: 'Sign in was unsuccessful.' }
      end
    end
  end

  def createUser
    @user = User.new(user_params)
    @status = Status.new
    @status.status_type = 2
    @status.status = " created an account"
    respond_to do |format|
      if @user.save
        user = User.find_by(username: @user.username, password: @user.password)
        session[:user_id] = user.id
        session[:username] = user.username 
        @status.user_id = session[:user_id]
        @status.save
        format.html { redirect_to dashboard_path, notice: 'Sign up was successful.' }
      else
        format.html { render :signUp }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def createProfile
      @profile = Profile.new(profile_params)
      @profile.user_id = session[:user_id]
      if params[:profile][:profile_picture].present?
        file = params[:profile][:profile_picture]
        dir = Rails.root.join('app','assets', 'images', 'user_assets', session[:username]) #GET DIRECTORY
        FileUtils.mkdir_p(dir) unless File.directory?(dir) #IF DIRECTORY EXISTS
        File.open(Rails.root.join(dir, "#{session[:username]}_profile_picture#{File.extname(file.original_filename) == '.jpg' ? '.jpeg' : File.extname(file.original_filename)}"), 'wb') do |f|
          f.write(file.read)
        end
        @profile.profile_picture = "user_assets/#{session[:username]}/#{session[:username]}_profile_picture#{File.extname(file.original_filename) == '.jpg' ? '.jpeg' : File.extname(file.original_filename)}"
      end

      if params[:profile][:home_picture].present?
        file = params[:profile][:home_picture]
        dir = Rails.root.join('app','assets', 'images', 'user_assets', session[:username]) #GET DIRECTORY
        FileUtils.mkdir_p(dir) unless File.directory?(dir) #IF DIRECTORY EXISTS
        File.open(Rails.root.join(dir, "#{session[:username]}_home_picture#{File.extname(file.original_filename) == '.jpg' ? '.jpeg' : File.extname(file.original_filename)}"), 'wb') do |f|
          f.write(file.read)
        end
        @profile.home_picture = "user_assets/#{session[:username]}/#{session[:username]}_home_picture#{File.extname(file.original_filename) == '.jpg' ? '.jpeg' : File.extname(file.original_filename)}"
      end

      respond_to do |format|
        if @profile.save
          format.html { redirect_to profile_path, notice: 'Profile updated.' }
        else
          format.html { render :index }
          format.json { render json: @profile.errors, status: :unprocessable_entity }
        end
      end
  end

  def updateUser
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to root_path, notice: 'User updated.' }
      else
        format.html { render :editProfile }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def updateProfile
    if params[:profile][:profile_picture].present?
      file = params[:profile][:profile_picture]
      dir = Rails.root.join('app','assets', 'images', 'user_assets', session[:username]) #GET DIRECTORY
      FileUtils.mkdir_p(dir) unless File.directory?(dir) #IF DIRECTORY EXISTS
      File.open(Rails.root.join(dir, "#{session[:username]}_profile_picture#{File.extname(file.original_filename) == '.jpg' ? '.jpeg' : File.extname(file.original_filename) == '.jpg' ? '.jpeg' : File.extname(file.original_filename)}"), 'wb') do |f|
        f.write(file.read)
      end
      @profile.profile_picture = "user_assets/#{session[:username]}/#{session[:username]}_profile_picture#{File.extname(file.original_filename) == '.jpg' ? '.jpeg' : File.extname(file.original_filename)}"
    end

    if params[:profile][:home_picture].present?
      file = params[:profile][:home_picture]
      dir = Rails.root.join('app','assets', 'images', 'user_assets', session[:username]) #GET DIRECTORY
      FileUtils.mkdir_p(dir) unless File.directory?(dir) #IF DIRECTORY EXISTS
      File.open(Rails.root.join(dir, "#{session[:username]}_home_picture#{File.extname(file.original_filename) == '.jpg' ? '.jpeg' : File.extname(file.original_filename)}"), 'wb') do |f|
        f.write(file.read)
      end
      @profile.home_picture = "user_assets/#{session[:username]}/#{session[:username]}_home_picture#{File.extname(file.original_filename) == '.jpg' ? '.jpeg' : File.extname(file.original_filename)}"
    end
    
    respond_to do |format|
      if @profile.update(profile_params)
        puts @profile.profile_picture
        format.html { redirect_to profile_path, notice: 'Profile updated.' }
      else
        format.html { render :index }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroyUser
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def destroySession
    reset_session
    redirect_to signin_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = Profile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :email, :password)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def login_params
      params.require(:user).permit(:username, :password)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(:fullname, :dateofbirth, :gender, :phone, :address, :nationality, :degree, :lifemotto, :summary, :id)
    end   
end
