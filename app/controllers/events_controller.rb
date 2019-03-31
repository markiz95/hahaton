require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets'

class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :join]

  # GET /events
  # GET /events.json
  def index
    @events = Event.includes(:tags, :members, :creator).all
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    @event.creator = current_user

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def join
    @event.users << current_user unless @event.users.include?(current_user)
    respond_to do |format|
      format.html { redirect_to events_url, notice: "See you on #{@event.title}" }
      format.json { render :index, status: :ok }
    # add_event_to_calendar # if @event.users.size == @event.min_people 
    update_event if @event.users.size > @event.min_people  # && !@event.users.include?(current_user)
    end
  end

  def add_event_to_calendar
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = google_secret.to_authorization
    service.authorization.fetch_access_token!
    start = @event.start.rfc3339
    end_time =  @event.end.rfc3339
    attendees = @event.users.map do |user| {email: user.email} end
    attendees << {email: @event.creator.email}
    new_event =  Google::Apis::CalendarV3::Event.new({
      summary: @event.title,
      location: 'event address',
      description: @event.description,
      start: { date_time: start, 'timeZone': "Europe/Minsk"},
      end: { date_time: end_time, 'timeZone': "Europe/Minsk" },
      guests_can_see_other_guests: true,
      attendees:  attendees,
      id: @event.id * 10000
    })
    service.insert_event('primary', new_event, send_updates: "all")
  end


  def update_event
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = google_secret.to_authorization
    service.authorization.fetch_access_token!
    ev = service.get_event('primary', @event.id * 10000) if service
    ev.attendees << {email: current_user.email}
    service.update_event('primary', @event.id * 10000 , ev)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:title, :description, :min_people, :max_people, :all_tags, :creator, :start, :end, :image)
  end

  def google_secret
    Google::APIClient::ClientSecrets.new(
      { "web" =>
        { "access_token" => current_user.token,
          "refresh_token" => current_user.google_refresh_token,
          "client_id" => Rails.application.secrets.google_client_id,
          "client_secret" => Rails.application.secrets.google_client_secret,
        }
      }
    )
  end

end
