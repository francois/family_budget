module WelcomeHelper
  def mini_form(object_name, options={})
    options.reverse_merge!(:from_label => "Quoi", :with_label => "Payé avec", :amount_label => "Montant")
    object = instance_variable_get("@#{object_name}")
    from, with = options[:from], options[:with]
    from_label, with_label, amount_label = options[:from_label], options[:with_label], options[:amount_label]
    render :partial => "welcome/form", :locals => {:object => object, :object_name => object_name, :from => from, :with => with, :from_label => from_label, :with_label => with_label, :amount_label => amount_label}
  end
end
