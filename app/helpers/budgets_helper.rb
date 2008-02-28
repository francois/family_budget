module BudgetsHelper
  MONTH_NAMES = %w(Janvier Février Mars Avril Mai Juin Juillet Août September Octobre Novembre Décembre)
  def month_name(month)
    MONTH_NAMES[month-1]
  end
end
