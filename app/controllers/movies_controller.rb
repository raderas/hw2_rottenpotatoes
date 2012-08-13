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

    
    params_string = "\?redir=1"
    self_redirect = false
    #Reading :params from session hash if it exists and redirecting if needed
    #debugger
    unless session[:ratings]==nil then
      if params[:ratings]==nil then
        #debugger
        session[:ratings].each {|hash_key,value| params_string << %q{&ratings[} << hash_key << %q{]=} << value }
        #debugger
        self_redirect = true
        #redirect_to movies_path << params_string
      else
        session[:ratings] = params[:ratings]
      end
    end

    #Reading :sort from session hash if it exists and redirecting if needed
    #This should be reviewed because sort may not come from a refresh button
    #push
    #TODO : Correct, the problem with this logic is that if both params
    #change, you get an infinite loop
#    unless session[:sort]==nil then
#      if params[:sort]==nil then
#        params_string << "\&sort=" << session[:sort]
#        self_redirect = true
#        else
#        session[:sort] = params[:sort]
#      end
#    else
#      if params[:sort] != nil then
#        session[:sort] = params [:sort]
#      end
#    end
#
#    if params[:sort] == nil then
#      if session[:sort] != nil then
#        params_string << "\&sort=" << session[:sort]
#        self_redirect = true
#      end
#    else
#      session[:sort] = params[:sort]
#    end

    #redirecting if needed
    if self_redirect then
      flash.keep
      redirect_to movies_path << params_string
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

end
