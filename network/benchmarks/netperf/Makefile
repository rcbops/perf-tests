# Copyright 2016 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

all: docker nptests push launch runtests

DOCKERREPO       := girishkalele/netperf-latest

docker: nptests launch
	mkdir -p Dockerbuild && \
	cp -f Dockerfile Dockerbuild/ && \
	cp -f nptest/nptests Dockerbuild/ &&\
	docker build -t $(DOCKERREPO) Dockerbuild/

push: docker
	gcloud docker push $(DOCKERREPO)

nptests: nptest/nptest.go
	cd nptest; GOOS=linux GOARCH=amd64 make nptests

clean:
	@rm -f Dockerbuild/*
	@rm -f ./nptests ./*svg ./*png ./*jpg ./*csv ./*.cap ./*.pyc nptests ./*~
	@go clean
	cd nptest; make clean

vendor: ./vendor/
	cp ../../vendor ./

launch: launch.go vendor
	docker build -f launch.dockerfile -t launch:latest ./

# 'runtests' is the test runner target
runtests: launch
	@echo Creating netperf Namespace and default CRB
	kubectl create ns netperf
	kubectl apply -f netperf-default-crb.yml
	@echo Launching network performance tests
	docker run --rm -it \
		-v $(KUBECONFIG):/kubeconfig \
		-v $(PWD):/app \
		launch:latest \
		/usr/local/bin/launch --kubeConfig /kubeconfig
	@echo Network performance tests complete
	@echo Running matplotlib to generate graphs and copy them back
	cp netperf-latest.csv plotperf
	$(MAKE) -c plotperf plot
	mv plotperf/*png ./
	mv plotperf/*svg ./
	@echo Results file netperf-latest.csv and SVG/PNG graphs generated successfully


