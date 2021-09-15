# frozen_string_literal: true

class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attachment :image
  
  #フォローしている人
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :followings, through: :relationships, source: :followed

  #フォローされている人
  has_many :re_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :re_relationships, source: :follower

  has_many :requests, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  #チャット機能
  has_many :chats, dependent: :destroy
  has_many :entries, dependent: :destroy

  #通知機能
  #通知を送る
  has_many :go_notifications,class_name: "Notification", foreign_key: "visitor_id", dependent: :destroy
  #通知を受け取る
  has_many :come_notifications,class_name: "Notification", foreign_key: "visited_id", dependent: :destroy

  
  #論理削除
  def active_for_authentication?
    super && (is_deleted == false)
  end

  #性別選択
  enum sex: {
    man: 0,      # 男性
    woman: 1,    # 女性
    other: 2 # その他
  }

  #フォロー機能
  def follow(member_id)
    relationships.create(followed_id: member_id)
  end

  def unfollow(member_id)
    relationships.find_by(followed_id: member_id).destroy
  end

  def following?(member)
    followings.include?(member)
  end

  #検索
  def self.looks(search)
    return Member.all unless search
    Member.where("nickname LIKE(?)", "%#{search}%")
  end
 
  #通知：フォロー
  def create_notification_follow!(current_member)
    temp = Notification.where([" visitor_id = ? and visited_id = ? and action =? " ,current_member.id, id, "follow"])
    if temp.blank?
      notification = current_member.go_notifications.new(visited_id: id, action: "follow")
      notification.save if notification.valid?
    end  
  end
end
