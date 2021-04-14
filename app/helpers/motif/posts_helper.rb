module Motif::PostsHelper
  def get_posts(company)
    if company.parent.present?
      company.posts + company.parent.posts
    else
      company.posts
    end
  end
end
