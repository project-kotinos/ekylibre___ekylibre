# -*- coding: utf-8 -*-
# == License
# Ekylibre - Simple ERP
# Copyright (C) 2008-2011 Brice Texier, Thibaud Merigon
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

class AnimalsController < AdminController
  manage_restfully :multipart => true
  respond_to :html, :xml, :pdf
  
  list do |t|
    t.column :identification_number, :url => true
    t.column :name, :url=>true
    t.column :name, :through=>:group, :url=>true
    t.column :born_on
    t.column :sex
    t.column :name, :through=>:mother, :url=>true
    t.column :income_on
    t.column :outgone_on
    t.action :show, :url=>{:format=>:pdf}, :image=>:print
    t.action :edit
    t.action :destroy, :if=>"RECORD.destroyable\?"
  end

  # Show a list of animal groups
  

  def print
    @animal = Animal.all
    respond_with @animal
  end

  def index
  end

  # Liste des soins de l'animal considéré
  list(:cares, :model=>:animal_cares, :conditions=>{:animal_id=>['session[:current_animal_id]']}, :order=>"start_on ASC") do |t|
    t.column :name
    t.column :start_on
    t.column :comment
  end

  # Liste des enfants de l'animal considéré
  list(:children, :model=>:animal, :conditions=>{:mother_id=>['session[:current_animal_id]']}, :order=>"born_on DESC") do |t|
    t.column :name, :url=>true
    t.column :born_on
    t.column :sex
    t.column :comment
  end

  # Show one animals with params_id
  def show
    respond_to do |format|
      return unless @animal = find_and_check(:animal)
      format.html do
        session[:current_animal_id] = @animal.id
        t3e @animal
      end
      format.pdf { render_print_animal(@animal) }
      format.json { render json: @animal }
      format.xml { render xml: @animal }
    end
  end

end
