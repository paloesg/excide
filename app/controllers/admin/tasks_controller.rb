module Admin
  class TasksController < Admin::ApplicationController
    before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Task.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Task.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def tasks_photos_upload
      @task = Task.find_by(id: params[:task_id])
      parsed_files = JSON.parse(params[:successful_files])
      parsed_files.each do |file|
        ActiveStorage::Attachment.create(name: 'photos', record_type: 'Task', record_id: @task.id, blob_id: ActiveStorage::Blob.find_by(key: file['response']['key']).id)
      end
      respond_to do |format|
        ## commented out because new tasks dont have anywhere to be redirected to
        #format.html { redirect_to edit_motif_franchisee_outlet_path(franchisee_id: @outlet.franchisee.id, id: @outlet.id), notice: "Photos successfully uploaded!" }
        format.json { render json: @files.to_json }
      end
    end

    private

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
  end
end
