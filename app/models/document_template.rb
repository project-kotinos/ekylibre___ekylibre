# = Informations
#
# == License
#
# Ekylibre - Simple agricultural ERP
# Copyright (C) 2008-2009 Brice Texier, Thibaud Merigon
# Copyright (C) 2010-2012 Brice Texier
# Copyright (C) 2012-2017 Brice Texier, David Joulin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# == Table: document_templates
#
#  active                :boolean          default(FALSE), not null
#  archiving             :string           not null
#  by_default            :boolean          default(FALSE), not null
#  compiled_content_type :string
#  compiled_file_name    :string
#  compiled_file_size    :integer
#  compiled_updated_at   :datetime
#  created_at            :datetime         not null
#  creator_id            :integer
#  formats               :string
#  id                    :integer          not null, primary key
#  language              :string           not null
#  lock_version          :integer          default(0), not null
#  managed               :boolean          default(FALSE), not null
#  name                  :string           not null
#  nature                :string           not null
#  source_content_type   :string

#  source_file_name      :string
#  source_file_size      :integer
#  source_updated_at     :datetime
#  updated_at            :datetime         not null
#  updater_id            :integer
#

# Sources are stored in :private/reporting/:id/content.xml
class DocumentTemplate < Ekylibre::Record::Base
  enumerize :archiving, in: %i[none_of_template first_of_template last_of_template none first last], default: :none, predicates: { prefix: true }
  refers_to :language
  refers_to :nature, class_name: 'DocumentNature'
  has_many :documents, class_name: 'Document', foreign_key: :template_id, dependent: :nullify, inverse_of: :template


  has_attached_file :compiled, path: ':tenant/:class/:id.jasper'
  validates_attachment_file_name :compiled,
    matches: [/jasper\z/],
    :message => :wrong_jasper_content_type


  # [VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates :active, :by_default, :managed, inclusion: { in: [true, false] }
  validates :archiving, :language, :nature, presence: true
  validates :compiled_content_type, :compiled_file_name, :formats, :source_content_type, :source_file_name, length: { maximum: 500 }, allow_blank: true
  validates :compiled_file_size, :source_file_size, numericality: { only_integer: true, greater_than: -2_147_483_649, less_than: 2_147_483_648 }, allow_blank: true
  validates :compiled_updated_at, :source_updated_at, timeliness: { on_or_after: -> { Time.new(1, 1, 1).in_time_zone }, on_or_before: -> { Time.zone.now + 50.years } }, allow_blank: true
  validates :name, presence: true, length: { maximum: 500 }
  # ]VALIDATORS]
  validates :language, length: { allow_nil: true, maximum: 3 }
  validates :archiving, :nature, length: { allow_nil: true, maximum: 60 }
  validates :nature, inclusion: { in: nature.values }

  selects_among_all scope: :nature

  # default_scope order(:name)
  scope :of_nature, lambda { |*natures|
    natures.flatten!
    natures.compact!
    return none unless natures.respond_to?(:any?) && natures.any?
    invalids = natures.select { |nature| Nomen::DocumentNature[nature].nil? }
    if invalids.any?
      raise ArgumentError, "Unknown nature(s) for a DocumentTemplate: #{invalids.map(&:inspect).to_sentence}"
    end
    where(nature: natures, active: true).order(:name)
  }

  scope :find_active_template, ->(name) do
    where(active: true)
      .where(name.is_a?(Integer) ? { id: name.to_i } : { by_default: true, nature: name.to_s })
      .first
  end

  protect(on: :destroy) do
    documents.any?
  end

  before_validation do
    # Check that given formats are all known
    unless formats.empty?
      self.formats = formats.to_s.downcase.strip.split(/[\s\,]+/).delete_if do |f|
        !Ekylibre::Reporting.formats.include?(f)
      end.join(', ')
    end
  end

  # Updates archiving methods of other templates of same nature
  after_save do
    if archiving.to_s =~ /\_of\_template$/
      self.class.where('nature = ? AND NOT archiving LIKE ? AND id != ?', nature, '%_of_template', id).update_all("archiving = archiving || '_of_template'")
    else
      self.class.where('nature = ? AND id != ?', nature, id).update_all(archiving: archiving)
    end
  end

  def check_compiled_content_type
   validates_attachment_file_name :compiled, matches: [/jasper\z/]
   if !['jasper'].include?(self.compiled_content_type)
    errors.add_to_base(t('activerecord.errors.messages.wrong_jasper_content_type')) # or errors.add
   end
  end

  # Install the source of a document template
  # with all its dependencies
  attr_writer :source

  # Returns source value
  attr_reader :source

  # Returns the expected dir for the source file
  def source_dir
    self.class.sources_root.join('document_templates')
  end

  # Returns the expected path for the source file
  def source_path
    source_dir.join("#{id.to_s}.jasper")
  end

  # Print a document with the given datasource and return raw data
  # Store if needed by template
  # @param datasource XML representation of data used by the template
  def print(datasource, key, format = :pdf, options = {})
    # Load the report
    report = Beardley::Report.new(source_path, locale: 'i18n.iso2'.t)
    # Call it with datasource
    data = report.send("to_#{format}", datasource)
    # Archive the document according to archiving method. See #document method.
    document(data, key, format, options)
    # Returns only the data (without filename)
    data
  end

  # Export a document with the given datasource and return path file
  # Store if needed by template
  # @param datasource XML representation of data used by the template
  def export(datasource, key, format = :pdf, options = {})
    # Load the report
    report = Beardley::Report.new(source_path, locale: 'i18n.iso2'.t)
    # Call it with datasource
    path = Pathname.new(report.to_file(format.to_sym, datasource))
    # Archive the document according to archiving method. See #document method.
    if document = self.document(path, key, format, options)
      FileUtils.rm_rf(path)
      path = document.file.path(:original)
    end
    # Returns only the path
    path
  end

  # Returns the list of formats of the templates
  def formats
    (self['formats'].blank? ? Ekylibre::Reporting.formats : self['formats'].strip.split(/[\s\,]+/))
  end

  def formats=(value)
    self['formats'] = (value.is_a?(Array) ? value.join(', ') : value.to_s)
  end

  # Archive the document using the given archiving method
  def document(data_or_path, key, _format, options = {})
    return nil if archiving_none? || archiving_none_of_template?

    # Gets historic of document
    archives = Document.where(nature: nature, key: key).where.not(template_id: nil)
    archives_of_template = archives.where(template_id: id)

    # Checks if archiving is expected
    return nil unless (archiving_first? && archives.empty?) ||
                      (archiving_first_of_template? && archives_of_template.empty?) ||
                      archiving.to_s =~ /\A(last|all)(\_of\_template)?\z/

    # Lists last documents to remove after archiving
    removables = []
    if archiving_last?
      removables = archives.pluck(:id)
    elsif archiving_last_of_template?
      removables = archives_of_template.pluck(:id)
    end

    # Creates document if not exist
    document = Document.create!(nature: nature, key: key, name: (options[:name] || tc('document_name', nature: nature.l, key: key)), file: File.open(data_or_path), template_id: id)

    # Removes useless docs
    Document.destroy removables

    document
  end

  @@load_path = []
  mattr_accessor :load_path

  class << self
    # Print document with default active template for the given nature
    # Returns nil if no template found.
    def print(nature, datasource, key, format = :pdf, options = {})
      if template = find_by(nature: nature, by_default: true, active: true)
        return template.print(datasource, key, format, options)
      end
      nil
    end

    # Returns the root directory for the document templates's sources
    def sources_root
      Ekylibre::Tenant.private_directory.join('attachments')
    end

    # Compute fallback chain for a given document nature
    def template_fallbacks(nature, locale)
      stack = []
      load_path.each do |path|
        root = path.join(locale, 'reporting')
        stack << root.join("#{nature}.jasper")
        fallback = {
          sales_order: :sale,
          sales_estimate: :sale,
          sales_invoice: :sale,
          purchases_order: :purchase,
          purchases_estimate: :purchase,
          purchases_invoice: :purchase
        }[nature.to_sym]
        if fallback
          stack << root.join("#{fallback}.jasper")
        end
      end
      stack
    end

    # Loads in DB all default document templates
    def load_defaults(options = {})
      locale = (options[:locale] || Preference[:language] || I18n.locale).to_s
      Ekylibre::Record::Base.transaction do
        manageds = where(managed: true).select(&:destroyable?)
        source_dir = manageds.map(&:source_dir).uniq.first

        nature.values.each do |nature|
          if source = template_fallbacks(nature, locale).detect(&:exist?)
            File.open(source, 'rb:UTF-8') do |f|
              unless template = find_by(nature: nature, managed: true)
                template = new(nature: nature, managed: true, active: true, by_default: false, archiving: 'last')
              end

              puts "nature: #{nature}".green
              puts "Template id: #{template.id}".green
              puts "Template methods: #{template.methods}".green

              unless template.source_file_name.nil?
                xml_file_path = source_dir.join(template.source_file_name)
                File.delete(xml_file_path) if File.exist?(xml_file_path)
              end

              unless template.compiled_file_name.nil?
                jasper_file_path = source_dir.join(template.compiled_file_name)
                File.delete(jasper_file_path) if File.exist?(jasper_file_path)
              end

              manageds.delete(template)
              template.attributes = { compiled: f, language: locale }
              template.name ||= template.nature.l
              template.save!
            end
            Rails.logger.info "Load a default document template #{nature}"
          else
            Rails.logger.warn "Cannot load a default document template #{nature}: No file found at #{source}"
          end
        end
        destroy(manageds.map(&:id))
      end
      true
    end
  end
end

DocumentTemplate.load_path << Rails.root.join('config', 'locales')
