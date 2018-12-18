json.array! @categories do |category|
  json.call(category, :id, :name, :label)
  json.type_id category.nature_id
end
