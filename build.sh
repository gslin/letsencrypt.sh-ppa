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

BASEDIR="${TMPDIR}/${NAME}-${VERSION}"
TARBALL="${NAME}-${VERSION}.tar"
TARBALL_GZ="${TARBALL}.gz"

rm -rf -- "${TMPDIR}"
mkdir -p "${TMPDIR}"

pushd "${TMPDIR}/"
git clone "${GIT_REPOSITORY_URL}" "${BASEDIR}/"
cd "${BASEDIR}/"
git checkout "${GIT_HASH}"
GIT_DATETIME="$(git log --format='%ci' HEAD...HEAD^)"
cd ..
tar -cv --exclude-vcs --mtime="${GIT_DATETIME}" -f "${TARBALL}" "${NAME}-${VERSION}/"
gzip -9 -n "${TARBALL}"
popd

cp -R debian/ "${BASEDIR}/"
pushd "${BASEDIR}/"
dh_make -f "../${TARBALL_GZ}" -s < /dev/null

# If we have already submitted this version before, use -i to increase version.
if grep -q "^${NAME} (${VERSION}" debian/changelog; then
    dch --distribution unstable -i
else
    dch --distribution unstable -v "${VERSION}-0ubuntu1~unstable~ppa1"
fi

popd
cp "${BASEDIR}/debian/changelog" debian/
