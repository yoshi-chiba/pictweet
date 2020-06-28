require 'rails_helper'

# RSpec.describe User, type: :model do
#   before doささ
#     @user = FactoryBot.build(:user)
#   end

#   describe 'ユーザー新規登録' do
#     it 'ニックネームが空だと登録できない' do
#       # FactoryBotを使用しない場合
#       # user = User.new(nickname: '', email: 'test@gmail.com', password: '0000000', password_confirmation: '0000000')
#       @user.nickname = ""
#       @user.valid?
#       expect(@user.errors.full_messages).to include("Nickname can't be blank")
#     end
#     it 'emailが空だと登録できない' do
#       # FactoryBotを使用しない場合
#       # user = User.new(nickname: 'test', email: '', password: '0000000', password_confirmation: '0000000')
#       @user.email = ""
#       @user.valid?
#       expect(@user.errors.full_messages).to include("Email can't be blank")
#     end
#   end
# end

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.build(:user)
  end

  describe 'ユーザー新規登録' do
    context '新規登録がうまくいくとき' do
      it "nicknameとemail、passwordとpassword_confirmationが存在すれば登録できる" do
        expect(@user).to be_valid
      end
      it "nicknameが6文字以下では登録できる" do
        @user.nickname = 'aaaaaa'
        expect(@user).to be_valid
      end
      it "passwordが6文字以上であれば登録できる" do
        @user.password = '0000000'
        @user.password_confirmation = '0000000'
        expect(@user).to be_valid
      end
    end

    context '新規登録がうまくいかないとき' do
      it "nicknameが空だと登録できない" do
        @user.nickname = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Nickname can't be blank")
      end
      it "nicknameが7文字以上であれば登録できない" do
        @user.nickname = 'aaaaaaa'
        @user.valid?
        expect(@user.errors.full_messages).to include("Nickname is too long (maximum is 6 characters)")
      end
      it "emailが空では登録できない" do
        @user.email = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Email can't be blank")
      end
      it "重複したemailが存在する場合登録できない" do
        @user.save
        another_user = FactoryBot.build(:user)
        another_user.email = @user.email
        another_user.valid?
        expect(another_user.errors.full_messages).to include("Email has already been taken")
      end
      it "passwordが空では登録できない" do
        @user.password = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Password can't be blank")  
      end
      it "passwordが5文字以下であれば登録できない" do
        @user.password = 'aaaaa'
        @user.valid?
        expect(@user.errors.full_messages).to include("Password is too short (minimum is 6 characters)")
      end
      it "passwordが存在してもpassword_confirmationが空では登録できない" do
        @user.password_confirmation = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Password confirmation doesn't match Password")
      end
    end
  end
end
