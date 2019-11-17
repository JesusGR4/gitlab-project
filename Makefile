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
	sed -i "s/FROM desatranques\/base/FROM ${DOCKER_IMAGE}\/base:${TEMPORAL_VERSION}/g" test/Dockerfile
	docker build -t ${DOCKER_IMAGE}/test:${TEMPORAL_VERSION} -f test/Dockerfile .
	docker push ${DOCKER_IMAGE}/test:${TEMPORAL_VERSION}

make-test-microservice:
	sed -i "s/desatranques\/${PROJECT}/${DOCKER_REGISTRY}\/${CI_PROJECT_NAME}\/${PROJECT}:${TEMPORAL_VERSION}/g" docker-compose-ci-test-${PROJECT}.yml
	sed -i "s/desatranques\/test/${DOCKER_REGISTRY}\/${CI_PROJECT_NAME}\/test:${TEMPORAL_VERSION}/g" test/docker-compose-ci-test-${PROJECT}.yml
	docker-compose -f docker-compose-ci-test-${PROJECT}.yml -f test/docker-compose-ci-test-${PROJECT}.yml build
	docker-compose -f docker-compose-ci-test-${PROJECT}.yml -f test/docker-compose-ci-test-${PROJECT}.yml run tester


make-test-gateway:
	sed -i "s/desatranques\/orders/${DOCKER_REGISTRY}\/${CI_PROJECT_NAME}\/${PROJECT}:${TEMPORAL_VERSION}/g" docker-compose-ci-test-gateway.yml
	sed -i "s/desatranques\/products/${DOCKER_REGISTRY}\/${CI_PROJECT_NAME}\/${PROJECT}:${TEMPORAL_VERSION}/g" docker-compose-ci-test-gateway.yml
	sed -i "s/desatranques\/gateway/${DOCKER_REGISTRY}\/${CI_PROJECT_NAME}\/${PROJECT}:${TEMPORAL_VERSION}/g" docker-compose-ci-test-gateway.yml
	sed -i "s/desatranques\/test/${DOCKER_REGISTRY}\/${CI_PROJECT_NAME}\/${PROJECT}:${TEMPORAL_VERSION}/g" test/docker-compose-ci-test-gateway.yml
	docker-compose -f docker-compose-ci-test-gateway.yml -f test/docker-compose-ci-test-gateway.yml build
	docker-compose -f docker-compose-ci-test-gateway.yml -f test/docker-compose-ci-test-gateway.yml run tester