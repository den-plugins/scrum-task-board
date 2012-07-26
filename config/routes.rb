class << ActionController::Routing::Routes
  def load_scrum_task_board_routes
    draw do |map|
      map.connect 'versions/task_board/:id', :controller => 'task_boards', :action => 'index'
      map.connect 'task_boards/:action/:id', :controller => 'task_boards', :action => 'index'
      map.resources :task_board, 
        :collection => {
          :init_distribution_summary => :post
        }
    end
    puts @routes
    additional_routes = @routes.dup
    reload!
    @routes += additional_routes
  end
  ActionController::Routing::Routes.load_scrum_task_board_routes
end
