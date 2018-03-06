# == Schema Information
#
# Table name: users
#
#  id                           :integer          not null, primary key
#  email                        :string(255)      default(""), not null
#  encrypted_password           :string(255)      default(""), not null
#  admin                        :boolean          default(FALSE), not null
#  locked                       :boolean          default(FALSE), not null
#  reset_password_token         :string(255)
#  reset_password_sent_at       :datetime
#  remember_created_at          :datetime
#  sign_in_count                :integer          default(0), not null
#  current_sign_in_at           :datetime
#  last_sign_in_at              :datetime
#  current_sign_in_ip           :string(255)
#  last_sign_in_ip              :string(255)
#  confirmation_token           :string(255)
#  confirmed_at                 :datetime
#  confirmation_sent_at         :datetime
#  unconfirmed_email            :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#  title                        :string(255)
#  first_name                   :string(255)
#  last_name                    :string(255)
#  phone                        :string(255)
#  website                      :string(255)
#  alt_website                  :string(255)
#  google_scholar               :string(255)
#  address                      :text(65535)
#  department                   :string(255)
#  other_organizations          :text(65535)
#  profile_picture_file_name    :string(255)
#  profile_picture_content_type :string(255)
#  profile_picture_file_size    :integer
#  profile_picture_updated_at   :datetime
#  country                      :string(255)
#  research_interests           :text(65535)
#  organisation_id              :integer
#  twitter                      :string(255)
#  editor                       :boolean          default(FALSE)
#

class User < ApplicationRecord
  # constants
  TITLES = ['Mr', 'Mrs', 'Miss', 'Ms', 'Dr', 'Prof.'].freeze

  # attributes
  attr_accessor :new_organisation_name

  # associations
  belongs_to :organisation, optional: true
  has_and_belongs_to_many :platforms
  has_and_belongs_to_many :publications
  has_and_belongs_to_many :presentations
  has_and_belongs_to_many :expeditions
  has_and_belongs_to_many :meetings
  has_and_belongs_to_many :photos
  has_many :validations
  has_many :posts
  has_one :featured_post, class_name: 'Post', primary_key: 'id', foreign_key: 'featured_user_id'
  has_attached_file :profile_picture,
                    default_url: '/images/:style/missing.png',
                    styles: { medium: '200x200>',
                              thumb: '100x100>' }

  # validations
  validates :email, format:
                    { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :website, allow_blank: true,
                      format: { with: URI.regexp(%w(http https)) }
  validates :alt_website, allow_blank: true,
                          format: { with: URI.regexp(%w(http https)) }
  validates :google_scholar, allow_blank: true,
                             format: { with: URI.regexp(%w(http https)) }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates_attachment :profile_picture,
                       content_type: { content_type: ['image/png',
                                                     'image/jpeg'] }

  # callbacks
  before_save :create_organisation_from_name

  # other
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :confirmable
  paginates_per 100

  # class methods
  def self.paged(page_number)
    order(admin: :desc, email: :asc).page page_number
  end

  def self.search_and_order(search, page_number)
    if search
      where('email LIKE ?', '%#{search.downcase}%')
        .order(admin: :desc, email: :asc).page page_number
    else
      order(admin: :desc, email: :asc).page page_number
    end
  end

  def self.last_signups(count)
    order(created_at: :desc).limit(count).select('id', 'email', 'created_at')
  end

  def self.last_signins(count)
    order(last_sign_in_at: :desc).limit(count)
      .select('id', 'email', 'last_sign_in_at')
  end

  def self.users_count
    where('admin = ? AND locked = ?', false, false).count
  end

  # instance methods
  def editor_or_admin?
    editor || admin
  end

  def full_name
    [last_name, first_name].join(', ')
  end

  def full_name_normal
    [first_name, last_name].join(' ')
  end

  def create_organisation_from_name
    new_organisation_name.blank? ||
      create_organisation(name: new_organisation_name)
  end

  def twitter_url
    twitter_name = twitter.tr("@", "")
    "http://www.twitter.com/#{twitter_name}"
  end
end
