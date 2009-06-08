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
    [controller.controller_name, controller.action_name] * " "
  end

  def render_flash_messages
    %w(notice error).map do |key|
      next if flash[key.to_sym].blank?
      content_tag(:p, h(flash[key.to_sym]), :class => key)
    end.join("\n")
  end

  def calendar
    year, month, day = current_date.year, current_date.month, current_date.day
    first_of_month = Date.new(year, month, 1)
    first_sunday = first_of_month - first_of_month.wday
    last_of_month = Date.new(year, month, 1) >> 1
    last_saturday = last_of_month + (6 - last_of_month.wday)
    returning([]) do |buffer|
      buffer << %q(<table cellspacing="0" cellpadding="0">)
      buffer << %Q(<caption>#{month_name(month)} #{year}</caption>)
      buffer << %q(<thead>)
      buffer << %q(<tr>)
      %w(Dim Lun Mar Mer Jeu Ven Sam).each do |dayname|
        buffer << %q(<th>)
        buffer << dayname
        buffer << %q(</th>)
      end
      buffer << %q(</tr>)
      buffer << %q(</thead>)
      buffer << %q(<tbody>)
      (first_sunday .. last_saturday).step(7) do |week|
        buffer << %q(<tr>)
        (week ... (week+7)).each do |date|
          classes = []
          classes << "today" if date == current_date
          classes << "outside" if date.month != month
          buffer << content_tag(:td, content_tag(:a, date.day, :href => "#"), :id => "date_#{date}", :class => classes.join(" "))
        end
        buffer << %q(</tr>)
      end
      buffer << %q(</tbody>)
      buffer << %q(</table>)
    end.join("\n")
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

      return image_tag(pc.to_url(options[:extras] || {}), :size => options[:size], :style => options[:style])
    end
  end

  def line_chart(data, options={})
    options.reverse_merge!(:size => "320x200", :title => "Pie Chart")
    GoogleChart::LineChart.new(options[:size], options[:title]) do |lc|
      data.each do |label, (points, color)|
        lc.data label, points, color
      end

      labels = dates_for_period.map {|d| d.strftime("%b")}
      lc.axis :x, :labels => labels
      lc.axis :y, :range => [0, data.map(&:last).map(&:first).flatten.compact.max]
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
