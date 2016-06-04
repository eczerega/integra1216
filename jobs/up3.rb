require "base64"
require 'openssl'

def generateHash (contenidoSignature)
  #PRODUCCION
  encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','Cfs%agh:i#B8&f6', contenidoSignature)).chomp
  #DESARROLLO
  #encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp
  return encoded_string
end

puts generateHash("GET")