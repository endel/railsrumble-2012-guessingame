class GameController < ApplicationController
  before_filter :prevent_cache, :only => [:ask, :answer]

  # GET
  def index
    @matters = Matter.all
    render :layout => 'login' unless @user.present?
  end

  # GET
  def ranking
    
  end

  # GET
  def play
    @matters = Matter.where(:id => params[:matters])
    session[:matters] = @matters.collect {|x| x.id }
  end

  # GET
  def ask
    # Time is up! No scoring and get another question.
    if params['timeout']
    end

    all_categories = Matter.where(:id => session[:matters]).collect {|x| x.categories.split(",") }

    @category = Category.where(:id => all_categories).order(db_rand_func).first
    @options = @category.pictures.order(db_rand_func).limit(6).to_a
    @answer = @options.first
    session['answer_id'] = @answer.id

    #
    # TODO: encode with JSON for security
    #
    # require "base64"
    # Base64.encode64({:picture => @picture, :options => @options.collect {|x| x.name }}.to_json)
    render :json => {:answer => @answer, :options => @options.as_json(:tiny => true)}
  end

  # POST
  def answer
    if session['answer_id'].to_s == params['answer_id']
      # Time in miliseconds
      total_score = (10000 - params['time'].to_i) / 100
      @user.score +=  total_score# Best score is 100 points per hit
      @user.save
      
      ranking = @user.rankings.where("matter_id = ? AND week_date = ?", params[:matter_id], Time.now.at_beginning_of_week).first
      if ranking.nil?
        @user.rankings.create(:matter_id => params[:matter_id], :week_date => Time.now.at_beginning_of_week, :score => total_score)
      else
        ranking.score += total_score
        ranking.save
      end
        
    end

    redirect_to :action => :ask
  end

  protected
    def db_rand_func
      (Rails.env.production?) ? 'RAND()' : 'RANDOM()'
    end
end
