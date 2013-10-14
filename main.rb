#!/usr/bin/env ruby

require "socket"
require "thread"

file = File.open("motd.txt", "r")
fichier = file.read
fichier = fichier.split("\n")
file.close

clients = []
dts = TCPServer.new('localhost', 20000)  
while(session = dts.accept)
  clients << session
  Thread.start(session) do |s| 
    s.puts('NICK ruby')
    s.puts(':server NOTICE ruby :Connecting to the matrix...')
    s.puts(':server 001 ruby :Matrix connection complete.')
    s.puts(':server 002 ruby :Your server running RubyIRCd')
    s.puts(':server 375 ruby :Welcome to RubyIRCd!')
    #motd
    fichier.each do |motd|
      s.puts(':server 372 ruby :' + motd)
    end
    s.puts(':server 376 ruby :End of /MOTD command.')
    #fin motd
    s.puts(':ruby!ruby@ruby JOIN #team-mondial')
    s.puts(':server 353 ruby = #team-mondial :unknow @root +ruby')
    while line = s.gets
      if line.start_with?("PING")
        reponse = line.split("PING ")
        s.puts('PONG ' + reponse[1])
      end
      if line.start_with?("PRIVMSG #")
        clients.each do |client_id|
          if client_id != s
            client_id.puts(':unknow!ruby@ruby ' + line)
          end
        end
      end
      if line.start_with?("TOPIC")
        clients.each do |client_id|
          if client_id != s
            client_id.puts(':unknow!ruby@ruby ' + line)
          end
        end
      end
      if line.start_with?("JOIN")
        channel = line.split(' ')
        s.puts(':ruby!ruby@ruby ' + line)
        s.puts(':server 353 ruby = ' + channel[1] + ' :unknow @root +ruby')
      end
      if line.start_with?("PART")
        s.puts(':ruby!ruby@ruby ' + line)
      end
      if line.start_with?("motd")
        fichier.each do |motd|
          s.puts(':server 372 ruby :' + motd)
        end
        s.puts(':server 376 ruby :End of /MOTD command.')
      end
      if line.start_with?("whois")
        nick = line.split(" ")
        s.puts(':server 311 ruby ' + nick[2] + ' ' + nick[2] +  ' ruby * : ruby')
        s.puts(':server 312 ruby ' + nick[2] + ' server :RubyIRCd')
        s.puts(':server 318 ruby ' + nick[2] + ' :End of /WHOIS list.')
      end
    end
  end  
end  
