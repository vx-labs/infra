all:: stack-net stack-core stack-identity

stack-%::
	docker stack deploy -c $*.yml $*

clean:: clean-identity clean-core clean-net

clean-%::
	docker stack rm $*
