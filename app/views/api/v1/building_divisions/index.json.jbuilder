json.array! @divisions do |division|
  json.call(division, :id, :name, :shape)
end
