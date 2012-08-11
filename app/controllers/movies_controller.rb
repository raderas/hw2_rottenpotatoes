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

    unless params[:ratings]==nil then
      #Variable for handling ratings filtering
      @rating_where_clause=Array.new
      params[:ratings].each do |selected_rating,value|
        @selected_ratings[selected_rating] = value
        @rating_where_clause << selected_rating
      end
    end

    #Header sorting and css formatting logic
    @title_header_class=nil
    @release_date_header_class=nil
    
    @order_string = ""
    
    case params[:sort]
    when "title"
      @order_string = "title ASC"
      #@movies = Movie.all(:order => "title ASC")
      @title_header_class = "hilite"
    when "release"
      @order_string = "release_date ASC"
      #@movies = Movie.all(:order => "release_date ASC")
      @release_date_header_class = "hilite"
    else
    #@movies = Movie.all
    @sort = "none"
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
