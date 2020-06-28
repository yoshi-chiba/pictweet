require 'rails_helper'

RSpec.describe "Users", type: :system do
  before do
    @user = FactoryBot.build(:user)
  end
  context "ユーザー新規登録ができるとき" do
    it "正しい情報を入力すればユーザー新規登録ができてトップページに移動する" do
      # トップページに移動する
      visit root_path
      # トップページにサインアップページへ遷移するボタンがある
      expect(page).to have_content("新規登録")
      # 新規登録ページへ移動する
      visit new_user_registration_path
      # ユーザー情報を入力する
      fill_in 'Nickname', with: @user.nickname
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      fill_in 'Password confirmation', with: @user.password_confirmation
      # サインアップボタンを押すと、ユーザーモデルのカウントが1上がる
      # expect{ "何かしらの動作" }.to change { モデル名.count }.by(1)
      expect{find('input[name="commit"]').click}.to change {User.count}.by(1)
      # トップページへ遷移する
      expect(current_path).to eq root_path
      # カーソルを合わせるとログアウトボタンが表示される
      expect(find(".user_nav").find("span").hover).to have_content("ログアウト")
      # サインアップページへ遷移するボタンやログインページへ遷移するボタンが表示されていない
      expect(page).to have_no_content('新規登録')
      expect(page).to have_no_content("ログイン")
    end
  end
  context "ユーザー新規登録ができないとき" do
    it "誤った情報ではユーザー新規登録ができずに新規登録ページへ戻ってくる" do
      # トップページへ遷移する
      visit root_path
      # トップページにサインアップページへ遷移するボタンがある
      expect(page).to have_content("新規登録")
      # 新規登録ページへ移動する
      visit new_user_registration_path
      # ユーザー情報を入力する
      fill_in "Nickname", with: ""
      fill_in "Email", with: ""
      fill_in "Password", with: ""
      fill_in "Password confirmation", with: ""
      # サインアップボタンを押しても、ユーザモデルのカウントが上がらない
      expect{find('input[name="commit"]').click}.to change {User.count}.by(0)
      # 新規登録ページへ戻される
      expect(current_path).to eq "/users"
    end
  end
end

RSpec.describe 'ログイン', type: :system do
  before do
    @user = FactoryBot.create(:user)
  end
  context 'ログインができる時' do
    it '保存されているユーザーの情報と一致すればログインできる' do
      # トップページに移動する
      visit root_path
      # トップページにログインボタンに遷移するボタンがある
      expect(page).to have_content("ログイン")
      # ログインページへ遷移する
      visit new_user_session_path
      # 正しいユーザー情報を入力する
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      # ログインボタンを押す
      find("input[name='commit']").click
      # トップページへ遷移する
      expect(current_path).to eq root_path
      # カーソルを合わせるとログアウトボタンが表示される
      expect(find(".user_nav").find("span").hover).to have_content("ログアウト")
      # サインアップページへ遷移するボタンやログインページへ遷移するボタンが表示されていない
      expect(page).to have_no_content("新規登録")
      expect(page).to have_no_content("ログイン")
    end
  end
  context 'ログインができない時' do
    it '保存されているユーザー情報と一致しないとログインできない' do
      # トップページへ移動する
      visit root_path
      # トップページにログインボタンに遷移するボタンがある
      expect(page).to have_content("ログイン")
      # ログインページへ遷移する
      visit new_user_session_path
      # 誤ったユーザー情報を入力する
      fill_in 'Email', with: ""
      fill_in 'Password', with: ""
      # ログインボタンを押す
      find("input[name='commit']").click
      # 新規登録ページへ戻される
      expect(current_path).to eq new_user_session_path
    end
  end
end