lint:
	bundle exec rufo .

helm-install:
	helm upgrade -i traceo kube/traceochart
