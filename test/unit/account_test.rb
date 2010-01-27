# = Informations
# 
# == License
# 
# Ekylibre - Simple ERP
# Copyright (C) 2009-2010 Brice Texier, Thibaud Mérigon
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
# 
# == Table: accounts
#
#  alpha        :string(16)       
#  comment      :text             
#  company_id   :integer          not null
#  created_at   :datetime         not null
#  creator_id   :integer          
#  deleted      :boolean          not null
#  groupable    :boolean          not null
#  id           :integer          not null, primary key
#  is_debit     :boolean          not null
#  keep_entries :boolean          not null
#  label        :string(255)      not null
#  last_letter  :string(8)        
#  letterable   :boolean          not null
#  lock_version :integer          default(0), not null
#  name         :string(208)      not null
#  number       :string(16)       not null
#  parent_id    :integer          default(0), not null
#  pointable    :boolean          not null
#  transferable :boolean          not null
#  updated_at   :datetime         not null
#  updater_id   :integer          
#  usable       :boolean          not null
#

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
