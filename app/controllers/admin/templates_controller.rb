module Admin
  class TemplatesController < Admin::ApplicationController
    before_action :set_s3_direct_post, only: [:new, :edit]
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Template.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Template.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
    def export
      @template = Template.find(params[:id])

      send_data @template.workflows_to_csv, filename: "#{@template.title}-#{Date.current}.csv"
    end

    def import
    end

    private

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
  end
end
