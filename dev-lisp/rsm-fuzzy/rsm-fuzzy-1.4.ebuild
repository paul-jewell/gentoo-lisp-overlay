# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit common-lisp-3

DESCRIPTION="R. Scott McIntire's Common Lisp Fuzzy Logic Library"
HOMEPAGE="http://packages.debian.org/unstable/devel/cl-rsm-fuzzy"
SRC_URI="mirror://debian/pool/main/c/cl-${PN}/cl-${PN}_${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND="!dev-lisp/cl-${PN}"

S="${WORKDIR}"/cl-${PN}

src_unpack() {
	unpack ${A}
}

src_prepare() {
	eapply "${FILESDIR}"/${PV}-gentoo-format-args.patch
	eapply_user
}

src_install() {
	common-lisp-install-sources *.lisp
	common-lisp-install-asdf
	dohtml ${PN}.html
}
