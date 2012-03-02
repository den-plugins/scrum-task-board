# Redmine Task Board

## Introduction

This plugin adds a 'Task Board' tab to your Project Menu for any Project with the 'Task Boards' module enabled (Settings>Modules). This tab will show the Task Board for the any Version. 

The task board is a visual representation of the Issues in the Sprint grouped by Issue Status. This plugin allows you to drag-n-drop Issues from one Status to another as you progress through the Sprint.

= Installation

Choose your poison:

 * git submodule add git://github.com/den-plugins/scrum-task-board.git  vendor/plugins/scrum_task_board
 * ./script/plugin install git://github.com/den-plugins/scrum-task-board.git

or

1. Extract or clone the plugin to vendor/plugins as scrum_task_board
3. Run <tt>rake db:migrate_plugins</tt> from RAILS_ROOT
4. Restart Redmine

= Dependencies

This plugin depends on the ff. plugins to run.
1. redmine-burndown
2. redmine-custom

= Compatibility

This plugin has only been tested in the following environments:

* Firefox 3.5.x Mac OS X
* Redmine 0.8.4 (including a private fork based on 0.8.0)

= License

Copyright (c) 2009 [Scrum Alliance](www.scrumalliance.org), released under the MIT license. 

Authored by:

* [Dan Hodos](mailto:danhodos[at]gmail[dot]com)
* [Doug Alcorn](mailto:dougalcorn[at]gmail[dot]com)
