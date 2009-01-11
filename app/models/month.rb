class Month
  attr_accessor :family, :year, :month

  def initialize(params={})
    self.attributes = params
  end

  def attributes=(params)
    params.each do |key, val|
      send("#{key}=", val)
    end
  end

  def date=(date)
    @year, @month = date.year, date.month
  end

  def valid?
    !(@family.blank? || [@year, @month].all?(&:blank?))
  end

  def errors
    @errors ||= ActiveRecord::Errors.new(self)
  end

  def budgets
    budgets = @family.budgets.for_period(@year, @month)
  end
end
