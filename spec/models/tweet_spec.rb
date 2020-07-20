require 'rails_helper'

RSpec.describe Tweet, type: :model do
  before do
    @tweet = FactoryBot.build(:tweet)
  end

  describe "tweetの保存" do
    context "tweetが保存できる場合" do
      it "画像とテキストがあれば保存できる" do
        expect(@tweet).to be_valid
      end
    end
    context "tweetが保存できない場合" do
      it "テキストがないと保存できない" do
        @tweet.text = ""
        @tweet.valid?
        expect(@tweet.errors.full_messages).to include("テキストを入力してください")
      end
      it "ユーザーが紐づいていないと保存できない" do
        @tweet.user = nil
        @tweet.valid?
        expect(@tweet.errors.full_messages).to include("Userを入力してください")
      end
    end
  end
end