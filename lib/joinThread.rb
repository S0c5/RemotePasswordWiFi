def joinThread(thread)
	thread.each do |t| 
		begin
			Timeout.timeout(10) do       
				t.join()
			end
		rescue Timeout::Error
			puts "[-] Timeout"
			t.kill()
		end
	end
	[]
end
