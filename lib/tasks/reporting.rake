require File.expand_path('../reporting/jasper_files_manager', __FILE__)

namespace :reporting do
  desc 'Compile all jrxml of config/locales directory'
  task compile: :environment do
    corporate_identity_file_path = Rails.root.join('config', 'corporate_identity', 'reporting_style.xml')

    locales_path = Rails.root.join('config', 'locales')
    locales_folders = Dir.entries(locales_path)

    locales_folders.each do |locale_folder|
      reporting_folder = locales_path.join(locale_folder, 'reporting')

      next unless File.exist?(reporting_folder)
      folder_entries = Dir.entries(reporting_folder).select { |f| f.include?('xml') }

      folder_entries.each do |source_file|
        source_file_name = source_file.split('.').first
        source_file_path = reporting_folder.join(source_file)
        tmp_source_file_path = reporting_folder.join("tmp_#{source_file}")
        compiled_file_path = reporting_folder.join("#{source_file_name}.jasper")

        puts '---'
        puts "Create tmp jrxml for #{source_file_path}".yellow
        JasperFilesManager.create_tmp_jrxml(source_file_path, corporate_identity_file_path, tmp_source_file_path)

        if File.exist?(tmp_source_file_path)
          puts "#{tmp_source_file_path} created!".green
        else
          puts "#{tmp_source_file_path} not created. 'style' or 'template' tags not exists in jrxml or xml file ?".red
          exit
        end

        puts "Compile jasper file with #{tmp_source_file_path}".yellow
        JasperFilesManager.compile_jasper_file(tmp_source_file_path, compiled_file_path)

        if File.exist?(compiled_file_path)
          puts "#{compiled_file_path} compiled!".green
        else
          puts "#{compiled_file_path} not compiled. Problem in compile process ?".red
          exit
        end

        puts "Delete #{tmp_source_file_path}".yellow
        JasperFilesManager.delete_file(tmp_source_file_path)

        if File.exist?(tmp_source_file_path)
          puts "#{tmp_source_file_path} not deleted. Bad path ?".red
          exit
        else
          puts "#{tmp_source_file_path} deleted!".green
        end

        puts "Update corporate identity tag #{source_file_path}".yellow
        JasperFilesManager.modify_jrxml(source_file_path)
        puts "#{source_file_path} updated!".green
        puts '---'
      end
    end
  end
end
