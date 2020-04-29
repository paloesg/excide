class ApplicationMailbox < ActionMailbox::Base
  # routing /something/i => :somewhere
  routing 'jon@excide.co' => :replies
end
