module DeviseHelper
  def devise_error_messages!
    return "" if @user.errors.empty?

    messages = @user.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => @user.errors.count,
                      :resource => @user.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation">
      <strong>#{sentence}</strong>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def devise_error_messages?
    @user.errors.empty? ? false : true
  end
end