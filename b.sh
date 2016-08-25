#!/bin/bash

GIT_REPOSITORY_URL=https://github.com/lukas2511/letsencrypt.sh.git
NAME=letsencrypt.sh

TMPDIR="/tmp/${NAME}"

if [[ "x$1" = "x" ]]; then
    cat <<EOF
Usage:
    $0 <tag or hash> [version name]

Example:
    $0 0.2.0
    $0 6192b33 0.2.0.20160822
EOF
    exit
else
    GIT_HASH="$1"
fi

if [[ "x$2" = "x" ]]; then
    VERSION="$1"
else
    VERSION="$2"
fi

rm -rf -- "${TMPDIR}"
mkdir -p "${TMPDIR}"

pushd "${TMPDIR}/"
git clone "${GIT_REPOSITORY_URL}" "${NAME}-${VERSION}/"
cd "${NAME}-${VERSION}/"
git checkout "${GIT_HASH}"
cd ..
tar -zcv --exclude-vcs -f "${NAME}-${VERSION}.tar.gz" "${NAME}-${VERSION}/"
popd
