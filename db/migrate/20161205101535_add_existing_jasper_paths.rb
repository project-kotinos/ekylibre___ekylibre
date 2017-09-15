class AddExistingJasperPaths < ActiveRecord::Migration
  def change

    reversible do |dir|
      dir.up do

        corporate_identity_file_path = Rails.root.join('config', 'corporate_identity', 'reporting_style.xml')

        tenant_folder = Rails.root.join('private', Ekylibre::Tenant::current)
        attachments_folder = tenant_folder.join('attachments')
        reporting_folder = tenant_folder.join('reporting')

        new_document_templates_folder = attachments_folder.join('document_templates')
        FileUtils.mkdir_p(new_document_templates_folder)

        document_templates_ids = select_values('SELECT id FROM document_templates')
        document_templates_ids.each do |document_template_id|

          old_source_file_name = "content.xml"
          new_source_file_name = "#{document_template_id}.xml"

          old_compiled_file_name = "content.xml.jasper"
          new_compiled_file_name = "#{document_template_id}.jasper"

          old_document_template_folder = reporting_folder.join(document_template_id.to_s)

          old_jrxml_file_path = old_document_template_folder.join(old_source_file_name)
          new_jrxml_file_path = new_document_templates_folder.join(new_source_file_name)

          old_compiled_file_path = old_document_template_folder.join(old_compiled_file_name)
          new_compiled_file_path = new_document_templates_folder.join(new_compiled_file_name)

          tmp_source_file_path = old_document_template_folder.join("tmp_#{old_source_file_name}")

          next unless File.exists?(old_jrxml_file_path)

          JasperFilesManager::create_tmp_jrxml(old_jrxml_file_path, corporate_identity_file_path, tmp_source_file_path)
          JasperFilesManager::compile_jasper_file(tmp_source_file_path, new_compiled_file_path)
          JasperFilesManager::delete_file(tmp_source_file_path)
          JasperFilesManager::remove_jasper_template_tag(old_jrxml_file_path)

          FileUtils.mv(old_jrxml_file_path, new_jrxml_file_path)

          if File.exists?(old_compiled_file_path)
            FileUtils.mv(old_compiled_file_path, new_compiled_file_path)
          end

          source_file_size = File.size(new_jrxml_file_path)
          compiled_file_size = File.size(new_compiled_file_path)

          update("
            UPDATE document_templates
            SET compiled_file_name = '#{new_compiled_file_name}',
                compiled_content_type = 'application/octet-stream',
                compiled_file_size = #{compiled_file_size},
                compiled_updated_at = '#{DateTime.now}',
                source_file_name = '#{new_source_file_name}',
                source_content_type = 'application/xml',
                source_file_size = #{source_file_size},
                source_updated_at = '#{DateTime.now}'
            WHERE id = #{document_template_id.to_s};
          ")

        end
        FileUtils.rm_rf(reporting_folder)
      end

      dir.down do
        execute <<-SQL
          -- UPDATE document_templates
          -- SET compiled_file_name = NULL,
          --     compiled_content_type = NULL,
          --     compiled_file_size = NULL;
        SQL
      end
    end
  end
end
