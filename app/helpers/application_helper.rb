module ApplicationHelper
  def page_title(title)
    @page_title = title
    content_tag(:h1, h(@page_title))
  end

  def body_classes
  end

  def render_flash_notices
    return nil if flash[:notice].blank?
    render :partial => "shared/notice"
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
end
