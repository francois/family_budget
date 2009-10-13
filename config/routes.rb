ActionController::Routing::Routes.draw do |map|
  map.resources :transfers
  map.resources :reports
  map.resource :budget do |budget|
    budget.resources :accounts, :only => :show
  end
  map.resource :welcome

  map.resources :bank_accounts, :as => "bank-accounts"
  map.resources :accounts, :splits

  map.resources :people, :families
  map.resources :bank_transactions, :as => "bank-transactions"
  map.resources :imports, :only => %w(new create show update destroy)
  map.resource :session

  map.root :controller => "dashboards", :action => "show"
end
