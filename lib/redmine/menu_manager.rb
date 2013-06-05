#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
#
# Copyright (C) 2012-2013 the OpenProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'redmine/menu_manager/menus'

module Redmine::MenuManager

  def self.map(menu_name, &menu_block)
    push menu_name, permanent_build_queue(menu_name), &menu_block
  end

  def self.loose(menu_name, &menu_block)
    push menu_name, temporary_build_queue(menu_name), &menu_block
  end

  def self.items(menu_name)
    items = {}

    potential_items = permanent_build_queue(menu_name)
    potential_items += temporary_build_queue(menu_name)

    reset_temporary_build_queues

    mapper = Mapper.new(menu_name.to_sym, items)

    potential_items.each do |menu_block|
      menu_block.call(mapper)
    end

    items[menu_name.to_sym] || Redmine::MenuManager::TreeNode.new(:root, {})
  end

  def self.exists?(menu_name)
    # TODO: have an explicit method for querying for undefined menus
    items(menu_name).children.size == 0
  end

  private

  class << self
    attr_accessor :menu_builder_queues, :temp_menu_builder_queues
  end

  private

  def self.permanent_build_queue(menu_name)
    self.menu_builder_queues ||= {}

    self.menu_builder_queues[menu_name] ||= []
  end

  def self.temporary_build_queue(menu_name)
    self.temp_menu_builder_queues ||= {}

    self.temp_menu_builder_queues[menu_name] ||= []
  end

  def self.reset_temporary_build_queues
    self.temp_menu_builder_queues = {}
  end

  def self.push(menu_name, queue, &menu_block)
    if menu_block
      queue.push menu_block
    else
      MapDeferrer.new queue
    end
  end
end
