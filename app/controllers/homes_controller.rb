class HomesController < ApplicationController
  def dashboard
  end

  # GET /homes
  # GET /homes.json
  def index
    zpid = [48749425, 56395012, 56327286, 56402744, 56540682, 56308076, 56408571, 56377387, 56436924, 56426063, 56377225, 56333485, 57470741, 56401419, 87730707, 56404397, 56327116, 87730221, 56268879]
    a = Array.new
    properties = Rails.cache.fetch("cached_array", :expires_in => 5.minutes) do
      zpid.each do |z|
        p = Rubillow::HomeValuation.zestimate({ :zpid => z })
        j = { :street => p.address[:street], :zpid => z, :lat => p.address[:latitude], :lng => p.address[:longitude], :zest => p.price }
        a.push j
      end
      a
    end
  
    @properties = properties.to_json

    # debugger;1

    @homes = Home.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @homes }
    end

  end

  def landing
  end

  # GET /homes/1
  # GET /homes/1.json
  def show
    @home = Home.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @home }
    end
  end

  # GET /homes/new
  # GET /homes/new.json
  def new
    @home = Home.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @home }
    end
  end

  # GET /homes/1/edit
  def edit
    @home = Home.find(params[:id])
  end

  # POST /homes
  # POST /homes.json
  def create
    @home = Home.new(params[:home])

    respond_to do |format|
      if @home.save
        format.html { redirect_to @home, notice: 'Home was successfully created.' }
        format.json { render json: @home, status: :created, location: @home }
      else
        format.html { render action: "new" }
        format.json { render json: @home.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /homes/1
  # PUT /homes/1.json
  def update
    @home = Home.find(params[:id])

    respond_to do |format|
      if @home.update_attributes(params[:home])
        format.html { redirect_to @home, notice: 'Home was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @home.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /homes/1
  # DELETE /homes/1.json
  def destroy
    @home = Home.find(params[:id])
    @home.destroy

    respond_to do |format|
      format.html { redirect_to homes_url }
      format.json { head :no_content }
    end
  end
end
