build-sample:
	cd ../"$(load_repo app-repo path)" && mvn package && docker pull icr.io/appcafe/open-liberty:kernel-slim-java11-openj9-ubi && docker build -t ${IMAGE} .

	# Push image to staging
	echo ${PIPELINE_PASSWORD} | docker login stg.icr.io -u "${PIPELINE_USERNAME}" --password-stdin
	docker push ${IMAGE}