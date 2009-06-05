ActionController::Routing::Routes.draw do |map|
  map.resources :transfers
  map.resources :reports
  map.resource :budget do |budget|
    budget.resources :accounts, :only => :show
  end
  map.resource :welcome

  map.resources :bank_accounts, :accounts, :splits

  map.resources :people, :families, :imports, :bank_transactions
  map.resource :session
  map.root :controller => "dashboards", :action => "show"

  map.resource :app, :only => :show
end
