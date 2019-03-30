require 'google/apis/calendar_v3'


class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    if request.env["omniauth.auth"].info["email"] !~ /@profitero\.com$/
      flash[:alert] = "You must enter under profitero user account."
      redirect_to new_user_session_path
      return
    end

    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)
    new_event
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authorization
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
    end
  end
  
  def client_options
    {
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      authorization_uri: @user[:token],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR
      }
  end
  
  def new_event
    @event = {
    'summary' => 'New Event Title',
    'description' => 'The description',
    'location' => 'Location',
    'start' => { 'dateTime' => Chronic.parse('tomorrow 4 pm') },
    'end' => { 'dateTime' => Chronic.parse('tomorrow 5pm') }}
  
    client = init_client
    client.code = params[:code]
    puts "+++++++++++"
    puts @user.inspect
    puts "_________________"
    
    # # client.update!(session[:authorization])
    # # client.code = params[:code]

    # # response = client.fetch_access_token!

    # # session[:authorization] =  @user[:token]
    # # client.update!(session[:authorization])
    # puts client.inspect
    # client.access_token = @token
    # client.id_token = @token
    # # client.grant_type = true
    # # redirect_to calendars_ur
    # service = Google::Apis::CalendarV3::CalendarService.new
    # service.authorization = client
    # # puts "lalalal"
    # # today = Date.today

    # # event = Google::Apis::CalendarV3::Event.new({
    # #   start: Google::Apis::CalendarV3::EventDateTime.new(date: today),
    # #   end: Google::Apis::CalendarV3::EventDateTime.new(date: today + 1),
    # #   summary: 'New event!'
    # # })

    # service.insert_event(params[:calendar_id], @event)

    # # redirect_to events_url(calendar_id: params[:calendar_id])
  end
  
  def init_client
    client = Signet::OAuth2::Client.new(client_options)
    return client
end
end
