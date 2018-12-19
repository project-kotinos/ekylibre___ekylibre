module Api
  module ProductsHelper
    def base64_picture(picture)
      return nil unless picture.present?
      io_readable_picture = Paperclip.io_adapters.for(picture)
      image_as_base64 = "data:"
      image_as_base64 << Rack::Mime.mime_type(io_readable_picture) << ";"
      image_as_base64 << "base64,"
      image_as_base64 << Base64.strict_encode64(io_readable_picture.read)
    end
  end
end
