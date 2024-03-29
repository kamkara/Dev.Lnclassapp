class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course, only: %i[ show edit update destroy ]
  before_action :find_levels, :find_materials

  # GET /courses or /courses.json
  def index
   #@courses = Course.feed.includes(:flashes, :user_echanges).all_ordered
    @courses = Course.feed.all_ordered
    
  end

  # GET /courses/1 or /courses/1.json
  def show
    
    #@line_item_dates = @quote.line_item_dates.includes(:line_items).ordered
    @flash_cards = @course.flash_cards.all_ordered
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses or /courses.json
  def create
    @course = current_user.courses.build(course_params)

    respond_to do |format|
      if @course.save
        format.html { redirect_to course_path(@course), 
           flash[:custom]= "La léçon est publiée." }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1 or /courses/1.json
  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to course_url(@course), notice: "Course was successfully updated." }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1 or /courses/1.json
  def destroy
    @course.destroy

    respond_to do |format|
      format.html { redirect_to courses_url, notice: "Course was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.friendly.find(params[:id])
    end

    def find_levels
      @levels = Level.all
    end

    def find_materials
      @materials = Material.all
    end

    # Only allow a list of trusted parameters through.
    def course_params
      params.require(:course).permit(:title, :content, :level_name, :material_name, :status, :published, :slug, :user_id)
    end
end
