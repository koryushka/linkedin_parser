json.array!(@grabs) do |grab|
  json.extract! grab, :id, :company, :links
  json.url grab_url(grab, format: :json)
end
