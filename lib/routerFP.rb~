module RouterFP
	@routers={
		:cisco => {
				:ssidUrl => "/wlanBasic.asp",
				:keyUrl => "/wlanSecurity.asp",
				:wepRex => //,
				:wpaRex => //,
				:ssidRex => //
	                   },
		:thomson => {
				:ssidUrl => "/wlanPrimaryNetwork.asp",
				:keyUrl => "/wlanPrimaryNetwork.asp",
				:wepRex => /input type=\"input\" name=\"NetworkKey1\" size=\"26\" maxlength=\"26\" value=(\w+)\>/,
				:wpaRex => /\<input type=\"password\" name=\"WpaPreSharedKey\" size=32 maxlength=64 value=\"([\S]+)\"\>/,
				:ssidRex => //
	                    },
		:technicolor => {
				:ssidUrl => "/wlanPrimaryNetwork.asp",
				:keyUrl => "/wlanPrimaryNetwork.asp",
				:wepRex => /input type=\"input\" name=\"NetworkKey1\" size=\"26\" maxlength=\"26\" value=(\w+)\>/,
				:wpaRex => /\<input type=\"password\" name=\"WpaPreSharedKey\" size=32 maxlength=64 value=\"([\S]+)\"\>/,
				:ssidRex => //
	                         }
	  }
	
	def self.getSSID(typeRouter)
		return @routers[typeRouter][:ssidUrl]
	end  
	def self.getKeyUrl(typeRouter)
		return @routers[typeRouter][:keyUrl]
	end
	def self.getRex(router,type)
		type=type.upcase
		
		routerTmp=@routers[router]
		case type
		when "WEP"
			return routerTmp["wepRex".to_sym]
		when "WPA"
			return routerTmp["wpaRex".to_sym]
		when "SSID"
			return routerTmp["ssidRex".to_sym]
		end
	end
	
end