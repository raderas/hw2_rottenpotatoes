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

    unless params[:redir] and params[:commit] != "refresh" then
      #If there is a params redir indication, then no session verification should be issued
      session_parameters = Hash.new
      params_string = String.new
      ratings_redirect = false
      sort_redirect = false

      #Check for ratings on params
      if params[:ratings] then
        #If there are ratings on params, we put them in session
        session[:ratings] = params[:ratings]
      else
      #If there are not ratings on params, we see if there are in session
        if session[:ratings] then
          #If there are ratings on session, we should redirect and a new URI should be generated
          session_parameters[:ratings] = session[:ratings]
        ratings_redirect = true
        end
      end

      #Check for sorting on params
      if params[:sort] then
        #If there is a sort instruction on params, we put it in session
        session[:sort] = params[:sort]
      else
      #If there isn't a sort instruction on params, see if there's one in session
        if session[:sort] then
          #If there is a sort instruction on session, we should redirect and a new URI should be generated
          #debugger
          session_parameters[:sort] = session[:sort]
        sort_redirect = true
        #If there is no sort on session either, nothing else should be done
        end
      end

      #If there is a redirect instruction, it should be processed
      if ratings_redirect || sort_redirect then
        #building the params instruction
        debugger
        params_string = "\?redir=1"
        if session_parameters[:ratings] then
          session_parameters[:ratings].each { |selected_rating| params_string << "\&ratings&[" << selected_rating << "&]=1" }
        end
        if session_parameters[:sort] then
          params_string << "\&sort=" << session_parameters[:sort]
        end
      self_redirect = true
      end

      #redirecting if needed
      if self_redirect then
        flash.keep
        redirect_to movies_path << params_string
      end
    end

    unless params[:ratings]==nil then
      #Variable for handling ratings filtering
      @rating_where_clause=Array.new
      params[:ratings].each do |selected_rating,value|
        @selected_ratings[selected_rating] = value
        @rating_where_clause << selected_rating
      end
      #saving :ratings on the session hash
      session[:ratings] =  params[:ratings]
    end

    #Header sorting and css formatting logic
    @title_header_class=nil
    @release_date_header_class=nil

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
