#!/bin/bash

TMPDIR=/tmp/letsencrypt.sh
URL_PREFIX=https://github.com/lukas2511/letsencrypt.sh/archive

if [[ "x$1" = "x" ]]; then
    cat <<EOF
Usage:
    $0 <version>
EOF
    exit
else
    VERSION="$1"
fi

BASEDIR="${TMPDIR}/letsencrypt.sh-${VERSION}"
TARBALL="letsencrypt.sh-${VERSION}.tar.gz"
URL="${URL_PREFIX}/v${VERSION}/${TARBALL}"

rm -rf -- "${TMPDIR}"
mkdir -p "${TMPDIR}"

wget -c -O "${TMPDIR}/${TARBALL}" -- "${URL}"
tar -zxv -C "${TMPDIR}" -f "${TMPDIR}/${TARBALL}"
cp -R debian/ "${BASEDIR}/"
pushd "${BASEDIR}/"
dh_make -f "../${TARBALL}" -s < /dev/null

# If we have already submitted this version before, use -i to increase version.
if grep -q "^letsencrypt.sh (${VERSION}" debian/changelog; then
    dch --distribution unstable -i
else
    dch --distribution unstable -v "${VERSION}-1ubuntu1~unstable~ppa1"
fi

popd
cp "${BASEDIR}/debian/changelog" debian/
