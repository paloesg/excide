class NotificationMailer < ApplicationMailer
  default from: 'Excide Symphony <admin@excide.co>'

  def self.deliver_notifications(task, action, users)
    users.each do |user|
      task_notification(task, action, user).deliver_now
    end
  end

  def task_notification(task, action, user)
    @task = task
    @action = action
    @user = user
    address = Mail::Address.new @user.email
    address.display_name = @user.first_name + @user.last_name
    @url  = 'https://calendly.com/sam-excide/'
    mail(to: address.format, subject: 'You have a new task to complete')
  end

  def create_activation(activation, user)
    @user = user
    @activation = activation
    address = Mail::Address.new @user.email
    address.display_name = @user.first_name + @user.last_name
    mail(to: address.format, subject: 'You have a new activation to complete')
  end

  def edit_activation(activation, user)
    @user = user
    @activation = activation
    address = Mail::Address.new @user.email
    address.display_name = @user.first_name + @user.last_name
    mail(to: address.format, subject: 'The activation has been changed')
  end

  def destroy_activation(activation, user)
    @user = user
    @activation = activation
    address = Mail::Address.new @user.email
    address.display_name = @user.first_name + @user.last_name
    mail(to: address.format, subject: 'The activation has been cancelled.')
  end
end
