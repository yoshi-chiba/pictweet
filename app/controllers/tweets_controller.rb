class TweetsController < ApplicationController
  before_action :set_tweet, only: [:edit, :show]
  # 未ログインユーザーであってもPrefixのnew_tweet_pathにあたる/tweets/newというパスへ直接アクセスすれば投稿ができてしまう。
  # それを回避するメソッドを定義する。
  before_action :move_to_index, except: [:index, :show, :search]

  def index
    # @tweetsは配列のような形になっている
    @tweets = Tweet.includes(:user).order("created_at DESC")
  end

  def new
    @tweet = Tweet.new
  end

  def create
    @tweet = Tweet.new(tweet_params)
    #バリデーションで問題があれば、保存はされず「投稿画面」に戻る
    if @tweet.valid?
      @tweet.save
      redirect_to root_path
    else
      #保存されなければ、newに戻る
      render 'new'
    end
  end

  def destroy
    # ビューにツイート情報を受け渡す必要はないので、インスタンス変数は用いない
    tweet = Tweet.find(params[:id])
    tweet.destroy
  end

  def edit
  end

  def update
    tweet = Tweet.find(params[:id])
    tweet.update(tweet_params)
  end

  def show
    @comment = Comment.new
    @comments = @tweet.comments.includes(:user)
  end

  # tweetモデルに定義
  def search
    @tweets = Tweet.search(params[:keyword])
  end


  private

  def tweet_params
    params.require(:tweet).permit(:image, :text).merge(user_id: current_user.id)
  end

  def set_tweet
    @tweet = Tweet.find(params[:id])
  end

  def move_to_index
    redirect_to action: :index unless user_signed_in?
  end
end
