#!/usr/bin/env coffee

fs = require 'fs'
coffeescript = require 'coffee-script'
argv = require('optimist').
	usage("Usage: $0 robot0 robot1 robotN [--host=host]").
	default('h', 'http://localhost:4321').
	alias('p', 'port').alias('h', 'host').
	argv

io = require 'socket.io-client'
socket = io.connect argv.h

Robot = require './Robot'

socket.on 'connect', ->
	console.log 'connected.'

	Robot.setSocket socket

	for filename in argv._
		robotext = fs.readFile "#{__dirname}/#{filename}", 'utf8', (err, code) ->
			if err
				console.error "Could not load robot #{filename} : #{err}"
				return

			try
				fn = new Function coffeescript.compile(code, bare:true)
				new Robot(fn)

				console.log "Loaded #{filename}"
			catch e
				console.log "Could not run #{filename}: #{e}"
				return



