class MathTrade < ActiveRecord::Base
	enum status: [:draft, :active, :pending, :finalized]
	belongs_to :moderator, class_name: "User"
	has_many :items, -> {order 'position asc' }, class_name: "MathTradeItem", :dependent => :destroy
	has_many :wants, class_name: "MathTradeWant"
	has_many :want_groups
	has_many :math_trade_want_confirmations
	
	acts_as_paranoid
	
	validates_presence_of :name, :offer_deadline, :wants_deadline
	validates_uniqueness_of :name, case_sensitive: false	
	
	validate :deadline_ordering
		
	def items_from_user(user)
		items.includes(:bgg_item).select { |x| x["user_id"] == user.id }
	end
	
	def users_in_trade
		items.group_by(&:user_id).keys.map { |x| User.find(x) }
	end
	
	def is_user_in_trade?(user)
		users_in_trade.any? { |x| x.id == user.id }
	end

	def get_user_wantlist(user)
		wants.includes(:item, item: :bgg_item).where(user_id: user.id)
	end
	
	def get_user_groups(user)
		want_groups.where(user_id: user.id)
	end
	
	def offers_due?
		return DateTime.now > offer_deadline
	end
	
	def wants_due?
		return DateTime.now > wants_deadline
	end
	
	def can_submit_items?
		!offers_due? && status == "active"
	end
	
	def can_submit_wants?
		!wants_due? && status == "active"
	end
	
	def confirmed_users
		return math_trade_want_confirmations.map { |x| x.user }
	end
	
	def can_view_results(user)
		!results_list.nil? && (status == "pending" || status == "finalized" || moderator_id == user.id)
	end
	
	def user_confirmation(user)
		math_trade_want_confirmations.where(user_id: user.id).first
	end
	
	def generate_wantlist(params)
		iterations = (params[:iterations] && params[:iterations].length > 0) ? params[:iterations] : 40
		seed = (params[:seed] && params[:seed].length > 0) ? params[:seed] : 1234567
		metric = params[:metric] || "users-trading"
		item_count = items.count
		wantlist = 
			<<~HEADER
				# Wantlist generated by Acceptable Trader (http://www.github.com/acceptableice/acceptable-trader)
				# Is there an issue with this file? Let us know by reporting an issue at the official repository.
				#
				# #{DateTime.now.strftime("%Y-%m-%d %H:%M:%S %Z") }
				# ID: #{id}
				# Trade: #{name} 
				# Moderator: #{moderator.bgg_account}
				# Items: #{item_count}
				# Users: #{items.select(:user_id).distinct.count}
				
				
				#! ALLOW-DUMMIES
				#! REQUIRE-COLONS
				#! REQUIRE-USERNAMES
				#! HIDE-NONTRADES
				#! SHOW-ELAPSED-TIME
				#! ITERATIONS=#{iterations}
				#! SEED=#{seed}
				#! METRIC=#{metric}
				
				
				!BEGIN-OFFICIAL-NAMES
				HEADER
				
		item_index_length = item_count > 0 ? Math.log(item_count, 10).ceil : 0
		item_code_reference = {}
		items.each_with_index do |item, index|
			if item.alt_name && item.alt_name.length > 0
				name = item.alt_name
			else
				bgg_item = item.to_bgg_item
				name = bgg_item ? bgg_item.name : "ITEM NOT IMPORTED"
			end
			item_code = "#{index.to_s.rjust(item_index_length, "0")}-#{item.id}-#{BggHelper.generate_short_name(name)}"
			wantlist += item_code
			wantlist += " ==> \"#{name}\" (from #{item.user.bgg_account})\n"
			item_code_reference[item.id] = item_code
		end
		
		wantlist += "!END-OFFICIAL-NAMES\n\n\n"
		
		confirmed_users.each do |user|
			wants = get_user_wantlist(user)
			group_codes = {}
			group_links_by_code = {}
			group_strings = get_user_groups(user).map do |group|
				group_items_list = group.want_items
					.map { |want_item| item_code_reference[want_item.math_trade_item_id] }

				group_code = "%#{group.short_name}"
				group_codes[group.id] = group_code
				group.want_links.each do |link|
					if group_links_by_code[item_code_reference[link.math_trade_want_id]].nil?
						group_links_by_code[item_code_reference[link.math_trade_want_id]] = []
					end
					group_links_by_code[item_code_reference[link.math_trade_want_id]].push(group_code)
				end
				
				"(#{user.bgg_account}) #{group_code} : #{group_items_list.join(" ")}"
			end
			
			group_strings_out = group_strings.length > 0 ? "\n" +  group_strings.join("\n\n") + "\n" : ""
			
			want_strings = items_from_user(user).map do |item|
				want_items_list = []

				wants.each do |want|
					if want.want_items.map(&:math_trade_item_id).include?(item.id)
						want_items_list.push(item_code_reference[want.math_trade_item_id])
					end	
				end			
							
				group_links = group_links_by_code[item_code_reference[item.id]]
				
				if !group_links.nil?
					(want_items_list << group_links).flatten!
				end
				if want_items_list.length > 0 && !item_code_reference[item.id].nil?
					"(#{user.bgg_account}) #{item_code_reference[item.id]} : #{want_items_list.join(" ")}"
				else
					nil
				end
			end
			
			want_strings = want_strings.compact
			
			wantlist +=
				<<~USERLIST
					# Wantlist for #{user.bgg_account}				
					#{group_strings_out}			
					#{want_strings.join("\n\n")}\n\n
				USERLIST
		end
		wantlist +=
			<<~FOOTER
				# This is the end of the wantfile. If you do not see this line on future exports,
				# something has gone wrong in the file creation process. 
			FOOTER
	end
	
	def parse_results
		if !results_list.nil?
			# Zero out existing items
			items.update_all(did_trade: false)
			results_start = results_list.index("TRADE LOOPS")
			results_end = results_list.index("ITEM SUMMARY")
			item_format = /\([\w]+\) [0-9]+-([0-9]+)-[A-Z0-9]+/
			if results_start > -1
				trade_data = { sending: {}, receiving: {} }
				results_lines = results_list[results_start..results_end].split("\n")
				results_lines.each do |line|
					matches = line.scan(item_format)
					if matches.length > 0
						user_receiving = items.find(matches[0][0].to_i).user
						item_sent = items.find(matches[1][0].to_i)
						item_sent.did_trade = true
						item_sent.save
						
						if trade_data[:receiving][user_receiving.id].nil?
							trade_data[:receiving][user_receiving.id] = []
						end
						
						if trade_data[:sending][item_sent.user.id].nil?
							trade_data[:sending][item_sent.user.id] = []
						end
						
						trade_data[:receiving][user_receiving.id].push(item_sent)
						trade_data[:sending][item_sent.user.id].push({item: item_sent, to: user_receiving.id })
					end
				end
				trade_data
			else
			 { error: true, message: "Invalid results list." }
			end
		else
			{ error: true, message: "No results list found." }
		end
	end
	
	def get_results
		value = Rails.cache.fetch("trade_#{id}/results")
		if value.nil?
			value = Rails.cache.fetch("trade_#{id}/results") do
				parse_results
			end
		end
		value
	end		
	
	def self.get_status_description(status)
		case status
		when "draft"
			"In Draft mode, this trade is only visible to you. You can make changes to its settings before " +  
			"listing it publicly without any worry of it affecting anyone who might join your trade."
		when "active"
			"In Active mode, this trade will be listed publicly. Users can join the trade and submit items freely."
		when "pending"
			"In Pending mode, this trade will no longer accept any changes. This mode is only available if a results file has been uploaded."
		when "finalized"
			"In Finalized mode, this trade will be locked. Users will be alerted that the trade has completed, and will be expected to ship their items."
		end
	end
	
	def self.filter_by(filter, user)
		trade_list = MathTrade.all.group_by(&:status)
		if user
			trade_list.each do |status, trades|
				case filter
				when "participating"
					trades.select! do |x| 
						any_items = x.items.any? { |i| i.user_id == user.id }
						(x.status != "draft" && any_items) || x.moderator_id == user.id
					end
				when "running"
					trades.select! { |x| x.moderator_id == user.id }
				else
					trades.select! { |x| x.status != "draft" || x.moderator_id == user.id }
				end
			end
		else 
			trade_list.each do |status, trades|
				trades.select! { |x| x.status == "active" || x.status == "finalized" }
			end
		end
		trade_list.delete_if { |k, v| v.length == 0 }
		trade_list
	end
	
	private
	
	def deadline_ordering
		if offer_deadline > wants_deadline
			errors.add(:base, "The offers deadline must be before the wants deadline.")
		end
	end
	
end