module DeviseHelper
  def devise_error_messages!
    return "" if @user.errors.empty?

    messages = @user.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => @user.errors.count,
                      :resource => @user.class.model_name.human.downcase)

    html = <<-HTML
    <div class="row d-flex justify-content-center">
      <div class="col-6">
        <div id='error_explanation' class='alert alert-danger' role='alert'>
          <div class="alert-close">
            <button aria-label="Close" data-dismiss="alert" type="button" class="close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <strong>#{sentence}</strong>
          <ul class="text-dark">#{messages}</ul>
        </div>
      </div>
    </div>
    HTML

    html.html_safe
  end

  def devise_error_messages?
    @user.errors.empty? ? false : true
  end
end
