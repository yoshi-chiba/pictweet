require 'rails_helper'

RSpec.describe "ツイートの投稿", type: :system do
  before do
    @user = FactoryBot.create(:user)
    @tweet_text = Faker::Lorem.sentence
    @tweet_image = Faker::Lorem.sentence
  end

  context "ツイートが投稿できる時" do
    it 'ログインしたユーザーは新規投稿できる' do
      # ログインする
      # visit new_user_session_path
      # fill_in "Email", with: @user.email
      # fill_in "Password", with: @user.password
      # find("input[name='commit']").click
      # expect(current_path).to eq root_path
      sign_in(@user)
      # 新規投稿ページへのリンクがある
      expect(page).to have_content("投稿する")
      # 投稿ページへ遷移する
      visit new_tweet_path
      # フォームに情報を入力する
      fill_in "tweet_text", with: @tweet_text
      fill_in "tweet_image", with: @tweet_image
      # 送信するとツイートのモデルのカウントが1増える
      expect{find("input[name='commit']").click}.to change {Tweet.count}.by(1)
      # 投稿完了ページへ遷移する
      expect(current_path).to eq tweets_path
      # 「投稿が完了しました」という文字がある
      expect(page).to have_content("投稿が完了しました")
      # トップページへ遷移する
      visit root_path
      # トップページには先ほど投稿した内容が反映されている(画像)
      expect(page).to have_selector(".content_post[style='background-image: url(#{@tweet_image});']")
      # トップページには先ほど投稿した内容が反映されている(テキスト)
      expect(page).to have_content(@tweet_text)
    end
  end
  context "ツイートが投稿できない時" do
    it 'ログインしていないと新規投稿ページに遷移できない' do
      # トップページへ遷移する
      visit root_path
      # 新規投稿ページへのリンクがない
      expect(page).to have_no_content('投稿する')
    end
  end
end

RSpec.describe 'ツイートの編集', type: :system do
  before do
    @tweet1 = FactoryBot.create(:tweet)
    @tweet2 = FactoryBot.create(:tweet)
  end
  context 'ツイートが編集できる時' do
    it 'ログインしたユーザーは自分が投稿したツイートの編集ができる' do
      # ツイート1を投稿したユーザーでログインする
      # visit new_user_session_path
      # fill_in "Email", with: @tweet1.user.email
      # fill_in "Password", with: @tweet1.user.password
      # find("input[name='commit']").click
      # expect(current_path).to eq root_path
      sign_in(@tweet1.user)
      # ツイート1に編集ボタンがある
      expect(all(".more")[1].hover).to have_link('編集'), href: edit_tweet_path(@tweet1)
      # 編集ページへ遷移する
      visit edit_tweet_path(@tweet1)
      # すでに投稿済みの内容がフォームに入っている
      expect(find("#tweet_image").value).to eq @tweet1.image
      expect(find("#tweet_text").value).to eq @tweet1.text
      # 投稿内容を編集する
      fill_in 'tweet_image', with: "#{@tweet1.image}+編集した画像URL"
      fill_in 'tweet_text', with: "#{@tweet1.text}+編集したテキスト"
      # 編集してもTweetモデルのカウントは変わらない
      expect{find('input[name="commit"]').click}.to change {Tweet.count}.by(0)
      # 編集完了画面へ遷移する
      expect(current_path). to eq tweet_path(@tweet1)
      # 更新が完了しましたの文字がある
      expect(page).to have_content('更新が完了しました')
      # トップページへ遷移する
      visit root_path
      # トップページには先ほど編集した内容のツイートが存在する(画像)
      expect(page).to have_selector(".content_post[style='background-image: url(#{@tweet1.image}+編集した画像URL);']")
      # トップページには先ほど編集した内容のツイートが存在する(テキスト)
      expect(page).to have_content("#{@tweet1.text}+編集したテキスト")
    end
  end
  context 'ツイートが編集できない時' do
    it 'ログインしたユーザーは自分以外が投稿したツイートの編集画面には遷移できない' do
      # ツイート1を投稿したユーザーでログインする
      # visit new_user_session_path
      # fill_in "Email", with: @tweet1.user.email
      # fill_in "Password", with: @tweet1.user.password
      # find("input[name='commit']").click
      # expect(current_path).to eq root_path
      sign_in(@tweet1.user)
      # ツイート2に編集ボタンがない
      expect(all(".more")[0].hover).to have_no_link('編集'), href: edit_tweet_path(@tweet2)
    end
    it 'ログインしていないとツイートの編集画面には遷移できない' do
      visit root_path
      expect(all(".more")[1].hover).to have_no_link('編集'), href: edit_tweet_path(@tweet1)
      expect(all(".more")[0].hover).to have_no_link('編集'), href: edit_tweet_path(@tweet2)
    end
  end
end

RSpec.describe 'ツイートの削除' do
  before do
    @tweet1 = FactoryBot.create(:tweet)
    @tweet2 = FactoryBot.create(:tweet)
  end
  context 'ツイートが削除できる時' do
    it 'ログインしたユーザーは自ら投稿したツイートを削除できる' do
      # ツイート1を投稿したユーザーでログインする
      # visit new_user_session_path
      # fill_in "Email", with: @tweet1.user.email
      # fill_in "Password", with: @tweet1.user.password
      # find("input[name='commit']").click
      # expect(current_path).to eq root_path
      sign_in(@tweet1.user)
      # ツイート1に削除ボタンがある
      expect(all(".more")[1].hover).to have_link("削除"), href: tweet_path(@tweet1)
      # 投稿を削除するとレコードの数が1減る
      expect{all(".more")[1].hover.find_link('削除', href: tweet_path(@tweet1)).click}.to change {Tweet.count}.by(-1)
      # 削除完了画面に遷移する
      expect(current_path).to eq tweet_path(@tweet1)
      # 削除が完了しましたの文字がある
      expect(page).to have_content("削除が完了しました")
      # トップページへ遷移する
      visit root_path
      # トップページにはツイート1の内容が存在しない(画像)
      expect(page).to have_no_selector(".content_post[style='background-image: url(#{@tweet1.image});']")
      # トップページにはツイート1の内容が存在しない(テキスト)
      expect(page).to have_no_content(@tweet1.text)
    end
  end
  context 'ツイートが削除できない時' do
    it 'ログインしたユーザーは自分自身が投稿したツイート以外は削除できない' do
      # ツイート1を投稿したユーザーでログインする
      # visit new_user_session_path
      # fill_in "Email", with: @tweet1.user.email
      # fill_in "Password", with: @tweet1.user.password
      # find("input[name='commit']").click
      # expect(current_path).to eq root_path
      sign_in(@tweet1.user)
      # ツイート2に削除ボタンがない
      expect(all(".more")[0].hover).to have_no_link('削除'), href: tweet_path(@tweet2)
    end
    it 'ログインしていないとツイートの削除ボタンが出てこない' do
      # トップページに遷移する
      visit root_path
      # ツイート1に削除ボタンがない
      expect(all(".more")[1].hover).to have_no_link("削除"), href: tweet_path(@tweet1)
      # ツイート2に削除ボタンがない
      expect(all(".more")[0].hover).to have_no_link("削除"), href: tweet_path(@tweet2)
    end
  end
end

RSpec.describe 'ツイートの詳細' do
  before do
    @tweet = FactoryBot.create(:tweet)
  end
  it 'ログインしたユーザーはツイート詳細ページへ遷移して、コメント投稿欄が表示される' do
    # ログインする
    # visit new_user_session_path
    # fill_in "Email", with: @tweet.user.email
    # fill_in "Password", with: @tweet.user.password
    # find("input[name='commit']").click
    # expect(current_path).to eq root_path
    sign_in(@tweet.user)
    # ツイートに詳細ボタンがある
    expect(all(".more")[0].hover).to have_link '詳細', href: tweet_path(@tweet)
    # 詳細ページに遷移する
    visit tweet_path(@tweet)
    # 詳細ページにツイートの内容が含まれている
    expect(page).to have_selector(".content_post[style='background-image: url(#{@tweet.image});']")
    expect(page).to have_content("#{@tweet.text}")
    # コメント用のフォームが存在する
    expect(page).to have_selector("form")
  end
  it 'ログインしていないユーザーはツイート詳細ページへ遷移できるものの、コメント投稿欄が表示されない' do
    # トップページに移動する
    visit root_path
    # ツイートに詳細ボタンがある
    expect(all(".more")[0].hover).to have_link '詳細', href: tweet_path(@tweet)
    # 詳細ページへ遷移する
    visit tweet_path(@tweet)
    # 詳細ページにツイートの内容が含まれている(画像)
    expect(page).to have_selector(".content_post[style='background-image: url(#{@tweet.image});']")
    # 詳細ページにツイートの内容が含まれている(テキスト)
    expect(page).to have_content("#{@tweet.text}")
    # フォームが存在しないことを確認する
    expect(page).to have_no_selector("form")
    # 「コメントの投稿には新規登録/ログインが必要です」が表示されていることを確認する
    expect(page).to have_content('コメントの投稿には新規登録/ログインが必要です')
  end
end