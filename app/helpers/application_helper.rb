require "google_chart"

module ApplicationHelper
  def protocol
    (Rails.env == "production" ? "https" : "http") + "://"
  end

  def page_title(title=nil)
    if title then
      @page_title = title
    else
      [h(@page_title), "NotreBudget.com"].reject(&:blank?).join(" &mdash; ")
    end
  end

  def body_classes
    [controller.controller_name, controller.action_name, logged_in? ? "authenticated" : "unauthenticated"] * " "
  end

  def render_flash_messages
    buffer = %w(notice error).map do |key|
      next if flash[key.to_sym].blank?
      content_tag(:p, h(flash[key.to_sym]), :class => key)
    end.join("\n")
    content_tag(:div, buffer + content_tag(:p, "Cliquez ici pour fermer", :class => "close"), :id => "flash", :style => "display:none") unless buffer.blank?
  end

  DAY_NAMES = %w(dimanche lundi mardi mercredi jeudi vendredi samedi)
  def render_current_date
    "#{DAY_NAMES[current_date.wday]} le #{current_date.day}"
  end

  MONTH_NAMES = %w(Janvier Février Mars Avril Mai Juin Juillet Août September Octobre Novembre Décembre)
  def month_name(month)
    MONTH_NAMES[month - 1]
  end

  def amount(value, default="")
    value && value.nonzero? ?  "%0.2f"%value : default
  end

  def when_logged_in?(&block)
    return nil unless logged_in?
    concat(capture(&block), block.binding)
  end

  def when_not_logged_in?(&block)
    return nil if logged_in?
    concat(capture(&block), block.binding)
  end

  def jquery_files
    if Rails.env == "development" then
      ["jquery.js", "jquery-ui.js"]
    else
      ["jquery.min.js", "jquery-ui.min.js"]
    end
  end

  FRENCH_DAY_NAMES   = %w(Dim Lun Mar Mer Jeu Ven Sam)
  FRENCH_MONTH_NAMES = %w(Jan Fév Mar Avr Mai Jui Jui Aoû Sep Oct Nov Dec)

  def i18n_date(date)
    "%s %d" % [FRENCH_DAY_NAMES[date.wday], date.day]
  end

  def format_money(amount)
    "%.2f" % amount
  end

  def pie_chart(data, options={})
    options.reverse_merge!(:size => "320x200", :title => "Pie Chart")
    GoogleChart::PieChart.new(options[:size], options[:title], false) do |pc|
      data.each do |line|
        pc.data line.first, line.last.to_f
      end

      return image_tag(pc.to_url(options[:extras] || {}), :size => options[:size])
    end
  end

  def expense_and_income_history_graph
    options = {:size => "480x200", :title => "Variation des revenus et dépenses"}
    GoogleChart::LineChart.new(options[:size], options[:title]) do |lc|
      incomes, expenses = total_incomes_per_period, total_expenses_per_period
      lc.data "Revenus",  incomes,  "00ff00"
      lc.data "Dépenses", expenses, "ff0000"

      labels = dates_for_period.map {|d| d.strftime("%b")}
      lc.axis :x, :labels => labels
      lc.axis :y, :range => [0, [incomes, expenses].flatten.max * 1.1]
      return image_tag(lc.to_url(options[:extras] || {}), :size => options[:size])
    end
  end

  def account_spending_history(account, dates)
    period  = (dates.sort.first .. (dates.sort.last >> 1))
    debits  = current_family.transfers.in_debit_accounts(account).within_period(period).group_amounts_by_period.all
    debits  = debits.index_by {|dt| Date.parse(dt.period)}
    credits = current_family.transfers.in_credit_accounts(account).within_period(period).group_amounts_by_period.all
    credits = credits.index_by {|dt| Date.parse(dt.period)}

    real_amounts = dates.inject([]) do |memo, date|
      debit_amount  = debits[date]
      credit_amount = credits[date]
      debit_amount  = debit_amount.amount  if     debit_amount
      credit_amount = credit_amount.amount if     credit_amount
      debit_amount  = 0                    unless debit_amount
      credit_amount = 0                    unless credit_amount
      memo << @account.normalize_amount(debit_amount, credit_amount)
    end

    budget_amounts = dates.inject([]) do |memo, date|
      memo << current_family.budgets.find_or_initialize_by_account_id_and_starting_on(account.id, date).amount
    end

    GoogleChart::BarChart.new("600x200", "Budgété vs Réel pour #{h(account.name)}") do |lc|
      lc.data "Budgété", budget_amounts, "cc9999"
      lc.data "Réel", real_amounts, "9999cc"

      lc.axis :x, :labels => dates.map {|d| d.strftime("%b")}
      lc.axis :y, :range => [0, (debits.to_a + credits.to_a).map(&:last).map(&:amount).max]

      return image_tag(lc.to_url(:chbh => "16,2,8"), :size => "600x200")
    end
  end
end
