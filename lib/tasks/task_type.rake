namespace :task_type do
  desc "TODO"
  task update: :environment do
    

    Task.all.each do |t|
      if t.task_type == "create_invoice_payable"
        t.task_type = 1000
        t.save
      elsif  t.task_type == "xero_send_invoice"
        t.task_type=1001
        t.save
      elsif  t.task_type == "create_invoice_receivable"
        t.task_type=1002
        t.save
      elsif  t.task_type == "coding_invoice"
        t.task_type=1003
        t.save
      end

    end

  end

 
end
