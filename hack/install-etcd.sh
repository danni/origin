#!/bin/bash

set -e

set -o errexit
set -o nounset
set -o pipefail

OS_ROOT=$(dirname "${BASH_SOURCE}")/..
source "${OS_ROOT}/hack/lib/init.sh"
os::log::stacktrace::install

etcd_version=$(go run ${OS_ROOT}/tools/godepversion/godepversion.go ${OS_ROOT}/Godeps/Godeps.json github.com/coreos/etcd/etcdserver)

mkdir -p "${OS_ROOT}/_output/tools"
cd "${OS_ROOT}/_output/tools"

if [ ! -d etcd ]; then
  mkdir -p etcd
  pushd etcd >/dev/null

  curl -s -L https://github.com/coreos/etcd/tarball/${etcd_version} | \
    tar xz --strip-components 1 --no-same-owner 2>/dev/null

  if [ "$?" != "0" ]; then
    echo "Failed to download coreos/etcd."
    exit 1
  fi
else
  pushd etcd >/dev/null
fi

# setup a private GOPATH so the build can succeed
export GOPATH="${PWD}/gopath"
rm -f "${GOPATH}/src/github.com/coreos/etcd"
mkdir -p "${GOPATH}/src/github.com/coreos"
ln -s "${PWD}" "${GOPATH}/src/github.com/coreos/etcd"

./build

echo
echo Installed coreos/etcd ${etcd_version} into:
echo export PATH=${PWD}/bin:\$PATH

popd >/dev/null
exit 0
