json.array! @zones do |zone|
  json.call(zone, :id, :name, :shape)
end
