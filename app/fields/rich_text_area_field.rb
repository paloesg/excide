require "administrate/field/text"

class RichTextAreaField < Administrate::Field::Text
  def to_s
    data
  end
end
