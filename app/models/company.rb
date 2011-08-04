class Company < ActiveRecord::Base
  include SearchEngine

  has_paper_trail :ignore => [:delta]
  acts_as_taggable_on :tags, :technologies
  sortable :created_at, :desc
  
  has_attached_file :logo, :styles => { :medium => '220x220', :thumb => '48x48' }, 
    :storage => :s3,
    :bucket => 'weworkinphilly',
    :s3_credentials => {
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
  }

  default_serialization_options :include => { :projects => {:include => [:tags, :technologies]}, 
                                              :groups => {:include => [:tags, :technologies]},
                                              :employees  => {:include => [:tags, :technologies]},
                                              :tags => {},
                                              :technologies => {}}

  has_many :company_projects
  has_many :projects, :through => :company_projects

  has_many :sponsorships
  has_many :groups, :through => :sponsorships

  has_many :employments
  has_many :employees, :through => :employments, :source => :person

  validates_presence_of :name

  # include Geocoder::Model
  # geocoded_by :address   # can also be an IP address
  # after_validation :geocode          # auto-fetch coordinates
  
  def map_url
    "http://maps.googleapis.com/maps/api/staticmap?center=#{clean_address}&zoom=14&size=200x220&maptype=roadmap&markers=color:blue%7C#{clean_address}&sensor=false"
  end
  
  def clean_address
    addr = address.gsub(" ", "+").gsub(",", "")
  end
  def geocoded_address
    address
  end
end




# == Schema Information
#
# Table name: companies
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  url               :string(255)
#  twitter           :string(255)
#  address           :text
#  description       :text
#  created_at        :datetime
#  updated_at        :datetime
#  logo_url          :string(255)
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer(4)
#  logo_updated_at   :datetime
#  delta             :boolean(1)      default(TRUE), not null
#

