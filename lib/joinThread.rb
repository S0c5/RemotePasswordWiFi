
def joinThread(thread)
	timeout=5
	
	thread.each do |t| 
		begin
			Timeout.timeout(timeout) do       
				t.join()
			end
		rescue Timeout::Error
			puts "[-] Timeout"
			
			if(timeout>10)
				timeout-=2
			else
				timeout+=2
			end
			t.kill()
		end
	end
	[]
end
