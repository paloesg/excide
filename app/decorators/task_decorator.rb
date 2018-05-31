class TaskDecorator < SimpleDelegator
  def workflow_action(workflow_identifier)
    workflow = Workflow.find_by(identifier: workflow_identifier)
    action = workflow_actions.find_by(workflow: workflow)

    return action
  end

  def display_position
    position.to_s + '.'
  end

  def display_image
    helpers.image_tag(image_url, class: "img-responsive") if image_url.present?
  end

  def display_role
    role&.name&.humanize
  end

  def helpers
    ActionController::Base.helpers
  end
end