include BggHelper 
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  after_create :send_verification_message
  validates_uniqueness_of :bgg_account, case_sensitive: false, message: "is already linked to another user."
         
  def bgg_user
	  if verified?
		  value = Rails.cache.fetch("user_#{id}/bgg_user_data")
		  if value.nil? || value.id == -1
			  Rails.cache.delete("user_#{id}/bgg_user_data")
			  value = Rails.cache.fetch("user_#{id}/bgg_user_data", expires_in: 12.hours) do
			  	BoardGameGem.get_user(bgg_account) rescue BGGUser.new
			  end
			 end
			 value
		else
			return nil
		end
	end
	
	def verified?
		return bgg_account_verified == true
	end
	
	def get_collection(filter = {})		
		value = Rails.cache.fetch("user_#{id}/collection")
		if value.nil?
			Rails.cache.delete("user_#{id}/collection")
			value = Rails.cache.fetch("user_#{id}/collection", expires_in: 12.hours) do
				BoardGameGem.get_collection(bgg_account)
			end
		end
		return value
	end
	
	def get_item_from_collection(id)
		collection = get_collection
		if !get_collection.nil?
			collection.items.select { |x| x.id == id}
		else
			nil
		end
	end
	
	def send_verification_message
		code = (0...20).map { (65 + rand(26)).chr }.join
		update_attributes bgg_account_verification_code: code
		
		link = "http://trade.acceptableice.com/bgg/verify_user_account?key=#{code}"
		BggHelper.send_mail_to_user(BoardGameGem.get_user(bgg_account),
			"Link your BGG Account to Acceptable Trader",
			"Heya, #{bgg_account}.\n\nWe've gotten a request to link your BGG account with Acceptable Trader. " +
			"Just click the link below and we'll wire it all up.\n\n
			#{link}\n\n
			Thanks,\n
			The Acceptable Trader Team"
		)
	end
		
end
