#!/bin/bash
# Copyright 2020 Red Hat, Inc. and/or its affiliates
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CSV_DIR="config/manifests/bases"
BUNDLE_CSV_DIR="bundle/manifests"
TEST_CONFIG_FILE="test/.default_config"

getOperatorVersion() {
  local version=$(grep -m 1 'Version =' version/version.go) && version=$(echo ${version#*=} | tr -d '"' | tr -d ' ')
  echo "${version}"
}

getLatestOlmReleaseVersion() {
  local tempfolder=$(mktemp -d)
  git clone https://github.com/k8s-operatorhub/community-operators/ "${tempfolder}" > /dev/null 2>&1
  local version=$(cd ${tempfolder}/operators/rhpam-kogito-operator && for i in $(ls -d */); do echo ${i%%/}; done | sort -V | tail -1)
  echo ${version}
}

getCsvFile() {
  echo "${CSV_DIR}/rhpam-kogito-operator.clusterserviceversion.yaml"
}

getBundleCsvFile() {
  echo "${BUNDLE_CSV_DIR}/rhpam-kogito-operator.clusterserviceversion.yaml"
}

getAllDependentCrds() {
  for crdKey in ${DEPENDENT_CRDS_KEYS[*]}
  do
    for crd in $(getDependentCrds ${crdKey})
    do
      echo "$crd"
    done
  done

  if [ "$1" = "all" ]
  then
    for crdKey in ${DEPENDENT_SENSITIVE_CRDS_KEYS[*]}
    do
      for crd in $(getDependentCrds ${crdKey})
      do
        echo "$crd"
      done
    done
  fi
}

getDependentCrds() {
  oc get crds | grep $1 | awk -F' ' '{print $1}'
}