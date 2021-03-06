class Admins::ContactsController < ApplicationController
  before_action :authenticate_member!, except: [:index, :edit, :update]
  before_action :authenticate_admin!
  
  def index
    @members = Member.all
    
    column = params[:column]
    # binding.pry
    if column.blank?
      @contacts = Contact.page(params[:page]).order(created_at: :desc).per(6)
    elsif column == "true"   
      @contacts = Contact.where(reply_status: true).page(params[:page]).order(created_at: :desc).per(6)
    elsif column == "false"
      @contacts = Contact.where(reply_status: false).page(params[:page]).order(created_at: :desc).per(6)
    end
  end

  def edit
    @contact = Contact.find(params[:id])
  end

  def update
    contact = Contact.find(params[:id])
    if contact.update(contact_params)
      contact.update(reply_status: true)
      #binding.pry
      member = contact.member
      ContactMailer.send_when_admin_reply(member, contact).deliver_now # 確認メールを送信
      redirect_to admins_contacts_path
      flash[:success] = '対応完了しました'
    else
      render :edit
      flash[:error] = 'エラーが発生しました' 
    end  
  end

  private

  def contact_params
    params.require(:contact).permit(:title, :body, :reply, :reply_status)
  end
end
