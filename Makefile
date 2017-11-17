all:: stack-net stack-core stack-identity stack-iot

stack-%::
	docker stack deploy -c $*.yml $*

clean:: clean-iot clean-identity clean-core clean-net

clean-%::
	docker stack rm $*
