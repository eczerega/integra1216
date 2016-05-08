require 'net/ssh'
require 'net/sftp'
require 'nokogiri'

CONTENT_SERVER_DOMAIN_NAME = "moto.ing.puc.cl"
CONTENT_SERVER_FTP_LOGIN = "integra12"
CONTENT_SERVER_FTP_PASSWORD = "365BLssd"





Net::SFTP.start(CONTENT_SERVER_DOMAIN_NAME, CONTENT_SERVER_FTP_LOGIN , :password => CONTENT_SERVER_FTP_PASSWORD) do |sftp|
i=0
sftp.dir.entries('/pedidos').each do |remote_file|
    if  remote_file.name != '.' && remote_file.name != '..'
      #results = File.open("./pedidos/"+remote_file.name, "a")
      file_data = sftp.download!('/pedidos' + '/' + remote_file.name)
      puts file_data
      doc = Nokogiri::XML(file_data)
    end
    puts 'ola vv'
  end
  i+=1
end
puts i