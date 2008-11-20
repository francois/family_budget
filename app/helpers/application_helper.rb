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
end
