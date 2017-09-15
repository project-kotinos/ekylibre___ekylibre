class AddJasperAttachmentsFilesColumns < ActiveRecord::Migration
  def up
    add_attachment :document_templates, :compiled
    add_attachment :document_templates, :source
  end

  def down
    remove_attachment :document_templates, :compiled
    remove_attachment :document_templates, :source
  end
end
