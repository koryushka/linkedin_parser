class GrabsController < ApplicationController
  before_action :set_grab, only: [:show, :edit, :update, :destroy]

  # GET /grabs
  # GET /grabs.json
  def index
    @grabs = Grab.all
  end

  # GET /grabs/1
  # GET /grabs/1.json
  def show
    @profiles = @grab.profiles
  end

  # GET /grabs/new
  def new
    @grab = Grab.new
  end

  # GET /grabs/1/edit
  def edit
  end

  # POST /grabs
  # POST /grabs.json
  def create
    @grab = Grab.new(grab_params)


      if @grab.save
        parse_profiles
        # format.html { redirect_to @grab, notice: 'Grab was successfully created.' }
        # format.json { render action: 'show', status: :created, location: @grab }
      else
        render action: 'new'
      end

  end

  # PATCH/PUT /grabs/1
  # PATCH/PUT /grabs/1.json
  def update
    respond_to do |format|
      if @grab.update(grab_params)
        format.html { redirect_to @grab, notice: 'Grab was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @grab.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grabs/1
  # DELETE /grabs/1.json
  def destroy
    if @grab.destroy
      respond_to do |format|
        format.html { redirect_to grabs_url }
        format.json { head :no_content }
      end
    end
  end

  def send_xls_file
    unless @grab
      @grab = Grab.find(params[:grab_id])
    end
    generate_xls
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grab
      @grab = Grab.find(params[:id])
    end

    def generate_xls
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      format = Spreadsheet::Format.new :color => :blue,
                                 :weight => :bold,
                                 :size => 10
      cols = ['Company name',
              'LinkedIn (company)',
              'First name',
              'Last name',
              'Email address',
              'Email',
              'Title',
              'Location',
              'Bounced',
              'Url']

      row = sheet.row(0)
      cols.length.times { |i| row.set_format(i, format)}
      cols.count.times { |j| sheet[0,j] = cols[j] }

      @grab.profiles.count.times do |j|
        sheet[j+1,0] = @grab.profiles[j].company_name
        sheet[j+1,1] = @grab.profiles[j].company_url
        sheet[j+1,2] = @grab.profiles[j].first_name
        sheet[j+1,3] = @grab.profiles[j].last_name
        sheet[j+1,4] = ''
        sheet[j+1,5] = ''
        sheet[j+1,6] = @grab.profiles[j].title
        sheet[j+1,7] = @grab.profiles[j].location
        sheet[j+1,8] = ''
        sheet[j+1,9] = @grab.profiles[j].url.squish

      end
      book.write "xlx/#{@grab.company}_#{@grab.created_at}.xls"
      download_xls
    end

    def parse_profiles
      require 'linkedin_scraper'
      links =  @grab.links.split("\n")
        links.each do |l|
          next if l.blank?
          begin
          get_profile(l)
          rescue Mechanize::ResponseCodeError => error
            puts "ERROR"
            sleep 2
            get_profile(l)
          end
        end
      generate_xls
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grab_params
      params.require(:grab).permit(:company, :links)
    end

    def get_profile(link)
      i = 0
      loop do
        profile = Linkedin::Profile.get_profile(link)
        i+=1
        break if i == 5
        if profile
          company =  profile.try(:current_companies).first
          if company && company[:linkedin_company_url]
            linkedin_company_url = company[:linkedin_company_url]
          end
          gp = @grab.profiles.build(
            company_name: @grab.company,
            company_url: linkedin_company_url,
            first_name: profile.first_name,
            last_name:profile.last_name,
            title: profile.title,
            location: profile.location,
            url: link)
          gp.save
          break
        else
          if i == 4
            gp = @grab.profiles.build(
              company_name: "Profile is closed",
              url: link)
            gp.save
          end
        end
      end
    end

    def download_xls
      send_file "#{Rails.root}/xlx/#{@grab.company}_#{@grab.created_at}.xls"
    end
end
