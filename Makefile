make-base:
	docker build --no-cache -t ${DOCKER_IMAGE}/base:${TEMPORAL_VERSION} .
	docker push $(DOCKER_IMAGE)/base:$(TEMPORAL_VERSION)

make-application:
	sed -i "s/FROM desatranques\/base/FROM ${DOCKER_REGISTRY}\/${CI_PROJECT_NAME}\/base:${TEMPORAL_VERSION}/g" ${PROJECT}/Dockerfile
	docker build --no-cache -t ${DOCKER_IMAGE}/${PROJECT}:${TEMPORAL_VERSION} ${PROJECT}/
	docker push ${DOCKER_IMAGE}/${PROJECT}:${TEMPORAL_VERSION}
		

make-publish:
	if [[ ${CI_COMMIT_REF_NAME} == release* ]]; then export VERSION=${CI_COMMIT_REF_NAME#*/}; else export VERSION=${CI_COMMIT_SHA}; fi
	docker pull $(DOCKER_IMAGE)/${PROJECT}:${TEMPORAL_VERSION}
	docker tag $(DOCKER_IMAGE)/${PROJECT}:${TEMPORAL_VERSION} $(DOCKER_IMAGE)/${PROJECT}:${VERSION}
	docker push $(DOCKER_IMAGE)/${PROJECT}:${VERSION}
