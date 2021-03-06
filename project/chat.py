# python prototype for cs131 project

import sys
import re
import json
import logging
import time
import datetime

from twisted.internet import reactor, protocol
from twisted.protocols.basic import LineReceiver
from twisted.web.client import getPage

apikey = "AIzaSyDsr8DYXDNDY2y0nh2fM93DEYkkGUxYUEk"
apiurl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"

ports = {
	"Alford"   : 12550,
	"Bolden"   : 12551,
	"Hamilton" : 12552,
	"Parker"   : 12553,
	"Powell"   : 12554
}

neighbors = {
	"Alford"   : ["Parker", "Powell"],
	"Bolden"   : ["Parker", "Powell"],
	"Hamilton" : ["Parker"],
	"Parker"   : ["Alford", "Bolden", "Hamilton"],
	"Powell"   : ["Alford", "Bolden"]
}


class ProxyHerdProtocol(LineReceiver):
	def __init__(self, factory):
		self.factory = factory

	def report(self, msg):
		log = "[{0}] : {1}.".format(self.factory.serverName, msg)
		logging.info(log)
		print log

	def connectionMade(self):
		self.factory.numClients += 1
		log = "[CONNECTION] Connection established, total: {0}".format(self.factory.numClients)
		self.report(log)

	def connectionLost(self, reasonLost):
		self.factory.numClients -= 1
		log = "[CONNECTION] Connection closed, total: {0}".format(self.factory.numClients)
		self.report(log)

	def lineReceived(self, line):
		self.report("[REQUEST] Recieved: {0}".format(line))

		args = line.strip().split(" ")

		if args[0] == 'IAMAT':
			self.respondIAMAT(line)
		elif args[0] == "WHATSAT":
			self.respondWHATSAT(line)
		elif args[0] == "AT":
			self.respondAT(line)
		else: # not found
			self.report("[REQUEST] Invalid request")
			self.transport.write(self.invalidLine(line))
			return


	def respondIAMAT(self, line):
		args = line.strip().split(" ")

		if len(args) != 4:
			self.report("[REQUEST] Invalid #args for 'IAMAT'")
			self.transport.write(self.invalidLine(line))
			return

		# bind the arguments
		_, clientID, clientCoord, ct = args

		clientTime = float(ct)
		if ct <= 0:
			self.report("[REQUEST] POSIX time has to be positive")
			self.transport.write(self.invalidLine(line))
			return

		timeDiff = time.time() - clientTime
		timeString = ""

		if timeDiff > 0:
			timeString = "+{0}".format(repr(timeDiff))
		else:
			timeString = "-{0}".format(repr(timeDiff))

		response = "AT {0} {1} {2} {3} {4}".format(self.factory.serverName, timeDiff, clientID, clientCoord, clientTime)
		self.transport.write(response + "\n")

		if clientID not in self.factory.users:
			self.report("[IAMAT] New client: {0}".format(clientID))
			self.factory.users[clientID] = {"msg" : response, "time" : clientTime}
			# flood
			self.propagateLocations(response, self.factory.serverName)
		else:
			if self.factory.users[clientID]['time'] > clientTime:
				self.report("[IAMAT] Existing client with fresher time: {0}".format(clientID))
				return
			else:
				self.report("[IAMAT] Existing client updated: {0}".format(clientID))
				self.factory.users[clientID] = {"msg" : response, "time" : clientTime}
				self.propagateLocations(response, self.factory.serverName)
		return

	def respondAT(self, line):
		args = line.strip().split(" ")

		if len(args) != 6:
			self.report("[REQUEST] Invalid #args for 'AT'")
			self.transport.write(self.invalidLine(line))
			return

		# bind arguments
		_, serverName, timeDiff, clientID, clientCoord, clientTime = args

		if clientID in self.factory.users and clientTime <= self.factory.users[clientID]["time"]:
			self.report("[AT] Existing client with fresher time: {0}".format(clientID))
			return

		if clientID in self.factory.users:
			self.report("[AT] Existing client updated: {0}".format(clientID))
		else:
			self.report("[AT] New client: {0}".format(clientID))

		self.factory.users[clientID] = {"msg" : line, "time" : clientTime}
		self.propagateLocations(line, self.factory.serverName)
		return

	def respondWHATSAT(self, line):
		args = line.strip().split(" ")

		if len(args) != 4:
			self.report("[REQUEST] Invalid #args for 'WHATSAT'")
			self.transport.write(self.invalidLine(line))
			return

		# bind arguments
		_, clientID, clientRadius, clientLimit = args

		# check if clientID exists
		if clientID not in self.factory.users:
			self.report("[WHATSAT] clientID '{0}' does not exist".format(clientID))
			return

		response = self.factory.users[clientID]["msg"]
		self.report("[WHATSAT] Found entry: {0}".format(response))
		_, _, _, _, clientCoord, _ = response.split(" ")

		# parse coordinates
		clientCoord = re.sub(r'[-]', ' -', clientCoord)
		clientCoord = re.sub(r'[+]', ' +', clientCoord).split()
		coord = clientCoord[0] + "," + clientCoord[1]

		# API request
		request = "{0}location={1}&radius={2}&sensor=false&key={3}".format(apiurl, coord, clientRadius, apikey)
		self.report("[WHATSAT] API request created: {0}".format(request))
		apiresponse = getPage(request)
		apiresponse.addCallback(
			lambda r:
			self.printLocations(r, int(clientLimit), clientID))
		return

	def invalidLine(self, line):
		invalidLine = "? {0}\n".format(line)
		return invalidLine

	def propagateLocations(self, response, sender):
		for name in neighbors[self.factory.serverName]:
			reactor.connectTCP('localhost', ports[name], ProxyHerdClient(response))
			self.report("[FLOOD] Sent location from {0} to {1}".format(self.factory.serverName, name))
		return

	def printLocations(self, response, clientLimit, clientID):
		jsonData = json.loads(response)
		results = json.dumps(jsonData, indent=4)
		self.report("[API] Google API response: {0}".format(results))
		msg = self.factory.users[clientID]["msg"]
		writeBack = "{0}\n{1}\n\n".format(msg, results)
		self.transport.write(writeBack)
		return


class ProxyHerdServer(protocol.ServerFactory):
	def __init__(self, serverName):
		self.serverName = serverName
		self.portNumber = ports[self.serverName]
		self.users = {}
		self.numClients = 0
		logFileName = self.serverName + ".log"
		logging.basicConfig(filename=logFileName, level=logging.DEBUG)
		log = "[{0}] : SERVER {1} started at PORT {2}.".format(self.serverName, self.serverName, self.portNumber)
		logging.info(log)

	def buildProtocol(self, addr):
		return ProxyHerdProtocol(self)

	def stopFactory(self):
		log = "[{0}] : SERVER {1} with PORT {2} stopped.".format(self.serverName, self.serverName, self.portNumber)
		logging.info(log)


class ProxyHerdClientProtocol(LineReceiver):
	def __init__(self, factory):
		self.factory = factory

	def connectionMade(self):
		self.sendLine(self.factory.message)
		self.transport.loseConnection()


class ProxyHerdClient(protocol.ClientFactory):
	def __init__(self, message):
		self.message = message

	def buildProtocol(self, addr):
		return ProxyHerdClientProtocol(self)


def main():
	if len(sys.argv) != 2:
		print "Error: incorrect number of command line arguments."
		exit()

	factory = ProxyHerdServer(sys.argv[1])
	reactor.listenTCP(ports[sys.argv[1]], factory)
	reactor.run()

if __name__ == '__main__':
	main()
