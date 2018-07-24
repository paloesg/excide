require "administrate/field/base"

class DatetimeField < Administrate::Field::Base
  def to_s
    data
  end
end
