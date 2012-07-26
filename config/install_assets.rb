root     = RAILS_ROOT
curr_dir = File.dirname(__FILE__)

js_dest    = %Q{#{root}/public/javascripts/scrum_task_board}
js_orig    = %Q{#{curr_dir}/../assets/javascripts/}
style_dest = %Q{#{root}/public/stylesheets/scrum_task_board}
style_orig = %Q{#{curr_dir}/../assets/stylesheets/}
image_dest = %Q{#{root}/public/stylesheets/scrum_task_board}
image_orig = %Q{#{curr_dir}/../assets/images/}

#clean all installed assets
FileUtils.rm_r js_dest, :force => true
FileUtils.rm_r style_dest, :force => true

#copy all js assets to <app>/public/javascripts/scrum_task_board
FileUtils.cp_r js_orig, js_dest

#copy all stylesheet assets to <app>/public/stylesheets/scrum_task_board
FileUtils.cp_r style_orig, style_dest

puts image_orig
puts image_dest
#copy all image assets to <app>/public/images
FileUtils.cp_r image_orig, image_dest
