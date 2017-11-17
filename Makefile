all:: stack-net stack-core

stack-%::
	docker stack deploy -c $*.yml $*

clean:: clean-net clean-core

clean-%::
	docker stack rm $*
