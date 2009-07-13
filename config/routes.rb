ActionController::Routing::Routes.draw do |map|
  map.resources :transfers
  map.resources :reports
  map.resource :budget do |budget|
    budget.resources :accounts, :only => :show
  end
  map.resource :welcome

  map.resources :bank_accounts, :accounts, :splits

  map.resources :people, :families, :bank_transactions
  map.resources :imports, :only => %w(new create show update destroy)
  map.resource :session
  map.root :controller => "dashboards", :action => "show"
end
