json.array! @categories do |category|
  json.call(category, :id, :name, :label)
end
