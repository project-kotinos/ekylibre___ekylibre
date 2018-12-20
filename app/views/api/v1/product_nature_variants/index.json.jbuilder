json.array! @variants do |variant|
  json.call(variant, :id, :name)
  json.type_id :nature_id
end
