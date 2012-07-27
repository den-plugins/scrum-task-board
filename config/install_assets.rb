root     = RAILS_ROOT
curr_dir = File.dirname(__FILE__)

asset_dest    = %Q{#{root}/public/plugin_assets/scrum_task_board}
asset_orig    = %Q{#{curr_dir}/../assets/}

#clean all installed assets
FileUtils.rm_r asset_dest, :force => true

#copy all js assets to <app>/public/plugin_assets/scrum_task_board
FileUtils.cp_r asset_orig, asset_dest
