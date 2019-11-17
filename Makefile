make-base:
	docker build --no-cache -t ${DOCKER_IMAGE}/base:${TEMPORAL_VERSION} .
	docker push $(DOCKER_IMAGE)/base:$(TEMPORAL_VERSION)

make-application:
	sed -i "s/FROM desatranques\/base/FROM ${DOCKER_REGISTRY}\/${CI_PROJECT_NAME}\/base:${TEMPORAL_VERSION}/g" ${PROJECT}/Dockerfile
	docker build --no-cache -t ${DOCKER_IMAGE}/${PROJECT}:${TEMPORAL_VERSION} ${PROJECT}/
	docker push ${DOCKER_IMAGE}/${PROJECT}:${TEMPORAL_VERSION}
		
make-publish:
	docker pull $(DOCKER_IMAGE)/${PROJECT}:${TEMPORAL_VERSION}
	docker tag $(DOCKER_IMAGE)/${PROJECT}:${TEMPORAL_VERSION} $(DOCKER_IMAGE)/${PROJECT}:${TEMPORAL_VERSION}
	docker push $(DOCKER_IMAGE)/${PROJECT}:${TEMPORAL_VERSION}

make-publish-release:
	docker pull $(DOCKER_IMAGE)/${PROJECT}:${TEMPORAL_VERSION}
	docker tag $(DOCKER_IMAGE)/${PROJECT}:${TEMPORAL_VERSION} $(DOCKER_IMAGE)/${PROJECT}:${RELEASE}
	docker push $(DOCKER_IMAGE)/${PROJECT}:${RELEASE}		

make-test-base:
	sed -i "s/FROM desatranques\/base/FROM ${DOCKER_REGISTRY}\/${CI_PROJECT_NAME}\/base:${TEMPORAL_VERSION}/g" test/Dockerfile
	docker build -t ${DOCKER_IMAGE}/test:${TEMPORAL_VERSION} -f test/Dockerfile .
	docker push ${DOCKER_IMAGE}/test:${TEMPORAL_VERSION}