# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit common-lisp-3

DESCRIPTION="Rewrite (X)HTML attributes with Common Lisp."
HOMEPAGE="http://www.weitz.de/url-rewrite/"
SRC_URI="http://common-lisp.net/~sionescu/files/${PN}_${PV}.orig.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND="!dev-lisp/cl-${PN}"

src_install() {
	common-lisp-install-sources *.lisp
	common-lisp-install-asdf
	dodoc CHANGELOG README
	dohtml doc/index.html
}
