class MoviesController < ApplicationController
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
  # will render app/views/movies/show.<extension> by default
  end

  def index

    #Display rating checkboxes logic
    @all_ratings = Movie.get_ratings
    @selected_ratings = Hash.new
    self_redirect = false

    unless params[:ratings]==nil then
      #Variable for handling ratings filtering
      @rating_where_clause=Array.new
      params[:ratings].each do |selected_rating,value|
        @selected_ratings[selected_rating] = value
        @rating_where_clause << selected_rating
      end
      #saving :ratings on the session hash
      session[:ratings] =  params[:ratings]
    else
    #If there is no :ratings on params, we'll check session
      if session[:ratings] != nil then
        #We construct a params string for redirecting
        params_string = "\?redir=1"
        session[:ratings].keys.each { |selected_rating| params_string << "\&ratings[" << selected_rating << "]=1" }
        session.delete(:ratings)
      self_redirect = true
      end
    end

    #Header sorting and css formatting logic
    @title_header_class=nil
    @release_date_header_class=nil

    if params[:sort] != nil then
      case params[:sort]
      when "title"
        @order_string = "title ASC"
        session[:sort] = params[:sort]
        #@movies = Movie.all(:order => "title ASC")
        @title_header_class = "hilite"
      when "release"
        @order_string = "release_date ASC"
        session[:sort] = params[:sort]
        #@movies = Movie.all(:order => "release_date ASC")
        @release_date_header_class = "hilite"
      else
      #@movies = Movie.all
      session[:sort] = "none"
      @order_string = ""
      end

    else
    #If there is no sort on params we check session
      if session[:sort] != nil then
        #We check if there's a params string already built and complete it
        if params_string == nil then
          params_string = "\?redir=1"
        end
        #Adding the sorting instruction to the params string
        params_string << "\&sort=" << session[:sort]
        session.delete(:sort)
        if params[:ratings] != nil then
          params[:ratings].keys.each { |selected_rating| params_string << "\&ratings[" << selected_rating << "]=1" }
          session[:ratings] = params[:ratings]
        end
      self_redirect =true
      end
    end

    if self_redirect
      flash.keep
      redirect_to movies_path << params_string
    end

    @movies = Movie.find(:all,:order => @order_string, :conditions => {:rating => @rating_where_clause})
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  #Function for looking for parameter on session
  def get_session_param(param_name)
    return session[param_name]
  end

  #Function for constructing parameters for url redirection if needed
  def build_params_for_address()

  end
end
