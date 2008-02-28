module WelcomeHelper
  def mini_form(object_name, options={})
    options.reverse_merge!(:debit_label => "Quoi", :credit_label => "Payé avec", :amount_label => "Montant")
    object = instance_variable_get("@#{object_name}")
    debit_accounts, credit_accounts = options[:debit_accounts], options[:credit_accounts]
    debit_label, credit_label, amount_label = options[:debit_label], options[:credit_label], options[:amount_label]
    render :partial => "welcome/form", :locals => {:object => object, :object_name => object_name, :debit_accounts => debit_accounts, :credit_accounts => credit_accounts, :debit_label => debit_label, :credit_label => credit_label, :amount_label => amount_label}
  end
end
