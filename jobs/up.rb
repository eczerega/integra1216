@dev = "/Users/eczerega/Desktop/taleer/appname/jobs/up.txt"
#@dev = "/home/administrator/appname/jobs/up.txt"
results = File.open(@dev, "a")
results << Time.now.to_s + ": Revisar facturas pagadas y despachar\n"
results.close