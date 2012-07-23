ActionController::Routing::Routes.draw do |map|
  map.show_task_board 'versions/task_board/:id', :controller => 'task_boards', :action => 'index'
  map.resources :task_board, 
    :collection => {
      :init_distribution_summary => :post
    }
end
