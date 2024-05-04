APP=$(shell basename $(shell git remote get-url origin) .git)
APP_LC = $(shell echo ${APP} | tr A-Z a-z)
GCLOUD_PROJECT_ID=strange-theme-417619
REGISTRY=eu.gcr.io/${GCLOUD_PROJECT_ID}
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

show-vars:
	@echo APP: ${APP}
	@echo APP_LC: ${APP_LC}
	@echo VERSION: ${VERSION}

get:
	cd src && go get

format:
	gofmt -s -w ./

# Build app for check Uptime Robot
build: format get show-vars
	cd src && CGO_ENABLED=0 go build -o app
# -----

# Build docker image
image: show-vars
	@echo TAG: ${REGISTRY}/${APP_LC}:${VERSION}
	docker build . -t ${REGISTRY}/${APP_LC}:${VERSION}
# -----

# Auth on Google Cloud before push
auth:
	gcloud auth login
	gcloud config set project ${GCLOUD_PROJECT_ID}
	gcloud auth configure-docker eu.gcr.io

push: show-vars
	docker push ${REGISTRY}/${APP_LC}:${VERSION}

clean:
	rm -f src/app
	docker rmi $(shell docker images ${REGISTRY}/${APP_LC} -q)
