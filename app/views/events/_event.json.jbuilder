json.extract! event, :id, :title, :description, :min_people, :max_people, :members_id, :creator_id, :start, :end, :created_at, :updated_at
json.url event_url(event, format: :json)
