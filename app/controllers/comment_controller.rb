class CommentController < ApplicationController
  protect_from_forgery with: :null_session, prepend: true
  
  def create
    render json: Comment.create(params['id'], params['body']);
  end
end
