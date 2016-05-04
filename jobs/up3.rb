@dev = "/Users/eczerega/Desktop/taleer/appname/jobs/up3.txt"
#@dev = "/home/administrator/appname/jobs/up3.txt"
results = File.open(@dev, "a")
results << Time.now.to_s + ": Sacar cosas del almacén de despacho\n"
results.close