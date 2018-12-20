json.array! @building_divisions do |division|
  json.call(division, :id, :name, :shape)
end
