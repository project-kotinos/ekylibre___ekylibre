class JasperFilesManager
  class << self

    CORPORATE_IDENTITIFY_FOLDER = 'corporate_identity'
    CORPORATE_IDENTITIFY_XML_FILE = 'reporting_style.xml'

    JASPER_XML_NAMESPACE = 'http://jasperreports.sourceforge.net/jasperreports'
    COMMENT_XPATH = '//comment()'
    TEMPLATE_XPATH = 'xmlns:template'
    JASPER_TEMPLATE_XPATH = '//jasperTemplate'
    STYLES_XPATH = 'xmlns:style'


    def modify_jrxml(source_file_path)
      document = get_xml_document(source_file_path)

      remove_comments(document)
      add_corporate_identity(source_file_path, document)

      write_file(source_file_path, document)
    end

    def create_tmp_jrxml(source_file_path, corporate_identity_file_path, tmp_source_file_path)
      source_document = get_xml_document(source_file_path)
      corporate_document = get_xml_document(corporate_identity_file_path)

      copy_jasper_template(source_document, corporate_document)

      write_file(tmp_source_file_path, source_document)
    end

    def remove_jasper_template_tag(source_file_path)
      source_document = get_xml_document(source_file_path)

      remove_document_tag(source_document, TEMPLATE_XPATH)

      write_file(source_file_path, source_document)
    end

    def compile_jasper_file(source_file_path, compiled_file_path)
      Beardley::Report.new(source_file_path).compile(source_file_path.to_s, compiled_file_path.to_s)
    end

    def delete_file(source_file_path)
      File.delete(source_file_path) if File.exist?(source_file_path)
    end

    private

      def get_xml_document(source_file_path)
        Nokogiri::XML(File.read(source_file_path)) do |config|
          config.noblanks.nonet.strict
        end
      end

      def remove_comments(document)
        document.xpath(COMMENT_XPATH).remove
      end

      def write_file(source_file_path, document)
        File.open(source_file_path, 'w') { |file| file.write(document.to_s) }
      end

      def add_corporate_identity(source_file_path, document)
        if jasper_file?(document)
          if template = document.root.xpath(TEMPLATE_XPATH).first
            template.children.remove
            style_file = Rails.root.join('config', CORPORATE_IDENTITIFY_FOLDER, CORPORATE_IDENTITIFY_XML_FILE)
            template.add_child(Nokogiri::XML::CDATA.new(document, style_file.dirname.relative_path_from(source_file_path).to_s.inspect))
          end
        end
      end

      def copy_jasper_template(document, corporate_document)
        if jasper_file?(document)
          if jasper_template = corporate_document.root.xpath(JASPER_TEMPLATE_XPATH).first

            styles = jasper_template.children
            template_tag = document.root.xpath(TEMPLATE_XPATH).first
            first_style_tag = document.root.xpath(STYLES_XPATH).first

            if !template_tag.nil?
              template_tag.add_next_sibling(styles)
              template_tag.remove
            elsif !first_style_tag.nil?
              first_style_tag.add_previous_sibling(styles)
            end
          end
        end
      end

      def remove_document_tag(document, tag_xpath)
        if jasper_file?(document)
          if template = document.root.xpath(tag_xpath).first
            template.remove
          end
        end
      end

      def jasper_file?(document)
        document.root && document.root.namespace && document.root.namespace.href == JASPER_XML_NAMESPACE
      end
  end
end
