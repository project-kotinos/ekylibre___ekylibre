json.array! @variants do |variant|
  json.call(variant, :id, :name, :label)
  json.type_id :nature_id
end
