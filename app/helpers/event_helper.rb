module EventHelper
  def user_friendly_date(datetime)
    datetime.strftime("%d %b %H:%m")
  end

  def date_range(event)
    if event.start && event.end
      if event.start.day == event.end.day && event.start.month == event.end.month
        "#{user_friendly_date(event.start)} - #{event.end.strftime("%H:%m")}"
      else
        "#{user_friendly_date(event.start)} - #{user_friendly_date(event.end)}"
      end
    elsif event.start || event.end
      user_friendly_date(event.start || event.end)
    end
  end

  def participants(event)
    event.max_people ? "#{event.members.size} from #{event.max_people}" : event.members.size
  end
end