require 'rubygems'
require 'rake'

Gem::Specification.new do |s|
  s.name = "redmine_task_board"
  s.version = "1.0.0"
  s.author = "Dan Hodos"
  s.email = ""
  s.description = "Creates a drag 'n' drop task board of the items in the current version and their status"
  s.homepage = "http://github.com/scrumalliance/redmine_task_board"
  s.platform = Gem::Platform::RUBY
  s.summary = "Centralized Projects Repository Management"
  s.files = FileList["*","{app,assets,db,lang,lib,test}/**/*"].to_a
  s.require_path = "lib"
  #s.autorequire = "name"
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.markdown"]
  #s.add_dependency("dependency", ">= 0.x.x")
end
