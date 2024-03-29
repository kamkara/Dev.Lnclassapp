class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable,
        :trackable,  :authentication_keys => [:logged]

has_many :levels, class_name: "Level", foreign_key: "user_id"
has_many :materials, class_name: "Material", foreign_key: "user_id"
has_many :schools, class_name: "School", foreign_key: "user_id"
has_many :citytowns, class_name: "Citytown", foreign_key: "user_id"
has_many :courses, class_name: "Course", foreign_key: "user_id"
has_many :flashes
has_many :flash_cards
has_many :user_echanges, class_name: "User_echange", foreign_key: "user_id"


            
attr_writer :logged
  #enum :role, student: "student", teacher: "teacher", team: "team", default: "student"
  
  
  ################## VALIDATES  ###############
  before_validation :user_validations?,  on: :create
  before_validation :full_name
   
  
   validates :first_name, :last_name, :full_name, :email, :password,
              :contact, :user_role, :city_name, presence: true

   validates :contact, uniqueness: true, numericality: { only_integer: true }, length: { minimum:10,
              message: "%{ value} verifier votre nom numéro est 10 chiffres"}
              
   validates :user_role, inclusion: { in: %w(Student Teacher Team ambassador),
                    message: "%{value} acces non identifier" }


   ############# CUSTOMIZE ###############""
   
   def user_validations?
    if self.user_role != "Student"
      self.matricule = "#{self.contact}T"
    else 
      self.email = "#{self.matricule}@gmail.com"
      self.password = "#{self.contact}"
    end    
  end

  #FULL_NAME
  def full_name
    self.full_name = "#{self.first_name} #{self.last_name}" 
  end 

################## SLUG ###############
  extend FriendlyId
  friendly_id :user_slugged, use: :slugged
  
  def user_slugged
    [
      :full_name,
    [:full_name, :contact]
    ]
  end
  ################## END SLUGGED #########

  ################## BEFORE SAVE  #########
  before_save do
    self.contact            = contact.strip.squeeze(" ")
    self.first_name         = first_name.strip.squeeze(" ").downcase.capitalize
    self.last_name          = last_name.strip.squeeze(" ").downcase.capitalize
  end
    
  ################## LOGGED  #########
  #permet la connexion avec le matricule
  def logged
    @logged || self.matricule || self.email
  end
  
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (logged = conditions.delete(:logged))
      where(conditions.to_h).where(["lower(matricule) = :value OR lower(email) = :value", { :value => logged.downcase }]).first
    elsif conditions.has_key?(:matricule) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end
  
  ################## End Logged  #########
end
