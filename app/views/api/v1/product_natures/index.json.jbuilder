json.array! @natures do |nature|
  json.call(nature, :id, :category_id, :name)
end
