json.array! @products do |product|
  json.call(product, :id, :name, :label, :category_id, :variant_id,
            :description, :number, :created_at)

  json.picture base64_picture(product.picture)
  json.unit product.unit_name
  json.zone_id product.current_localization && product.current_localization.id
  json.type_id product.nature_id
end
