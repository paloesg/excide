class ApplicationMailbox < ActionMailbox::Base
	POSTS_REGEX = /jon@excide.co/i
  # routing /something/i => :somewhere
  routing POSTS_REGEX => :replies
end
