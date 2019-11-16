make-base:
	docker build --no-cache -t ${DOCKER_IMAGE}/base:${VERSION} .
	docker push $(DOCKER_IMAGE)/base:$(VERSION)

make-application:
	sed -i "s/FROM desatranques\/base/FROM ${DOCKER_REGISTRY}\/${CI_PROJECT_NAME}\/base:${VERSION}/g" ${PROJECT}/Dockerfile
	docker build --no-cache -t ${DOCKER_IMAGE}/${PROJECT}:${VERSION} ${PROJECT}/

make-publish:
	docker push ${DOCKER_IMAGE}/${PROJECT}:${VERSION}