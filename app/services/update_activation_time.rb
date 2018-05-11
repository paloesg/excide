class UpdateActivationTime

  def self.time_changed(params, activation)
    activation.transaction do
      activation.allocations.transaction do
        if activation.allocations.update_all(allocation_date: params['start_time'], start_time: params['start_time'], end_time: params['end_time'])
          activation.allocations.each do |allocation|
            if allocation.user.availabilities.where("start_time <= ?", params['start_time']).where("end_time >= ?", params['end_time']).present?
              NotificationMailer.edit_activation(activation, allocation.user).deliver
            else
              NotificationMailer.removed_from_activation(activation, allocation.user).deliver
              allocation.update_attribute(:user_id, nil)
            end if allocation.user
          end
        end
        activation.update(params)
      end
    end
  end

end