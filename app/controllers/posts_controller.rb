class PostsController < ApplicationController
  before_action :not_logged_in, only: [:new, :create]
  before_action :wrong_user, only: [:edit, :update, :destroy]

  def new
    @post = Post.new
    @subs = Sub.alpha_order(:title).select(:id, :title)
    render :new
  end

  def create
    @post = Post.new(post_params)
    @post.add_author(current_user.id)

    if @post.save
      redirect_to post_url(@post)
    else
      @subs = Sub.alpha_order(:title).select(:id, :title)
      flash.now[:error] = @post.errors.full_messages
      render :new
    end
  end

  def show
    post_data = Post.where(id: params[:id]).includes(comments: [:author]).create_order
    @post = post_data.first
    @comments = @post.comments
    @author = @post.author
    @subs = @post.subs.alpha_order(:title)
    render :show
  end

  def edit
    @post = Post.find_by_id(params[:id])
    @subs = Sub.alpha_order(:title).select(:id, :title)
    render :edit
  end

  def update
    @post = Post.find_by_id(params[:id])

    if @post.update_attributes(post_params)
      redirect_to post_url(@post)
    else
      @subs = Sub.alpha_order(:title).select(:id, :title)
      flash.now[:error] = @post.errors.full_messages
      render :edit
    end
  end

  def destroy
    @post = Post.find_by_id(params[:id])

    if @post.destroy
      redirect_to subs_url
    else
      flash[:error] = "Oops, something went wrong. Post still exists."
      render :show
    end
  end

  private

  def wrong_user
    post = Post.find_by_id(params[:id])
    return if post.author == current_user
    redirect_to post_url(post)
  end

  def post_params
    params.require(:post).permit(:title, :url, :content, sub_ids: [])
  end
end