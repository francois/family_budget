ActionController::Routing::Routes.draw do |map|
  map.resources :transfers
  map.resources :reports
  map.resource :budget, :welcome

  map.resources :bank_accounts, :accounts

  map.resources :people, :families, :imports, :bank_transactions
  map.resource :session
  map.root :controller => "welcomes", :action => "show"
end
