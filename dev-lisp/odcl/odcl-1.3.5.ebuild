# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit common-lisp-2 eutils

DESCRIPTION="A Common Lisp library of utility functions."
HOMEPAGE="http://packages.debian.org/unstable/devel/cl-odcl"
SRC_URI="mirror://debian/pool/main/c/cl-${PN}/cl-${PN}_${PV}.orig.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND="!dev-lisp/cl-${PN}"

S="${WORKDIR}"/cl-${P}

src_unpack() {
	unpack ${A}	&& cd "${S}"
	epatch "${FILESDIR}"/${PV}-package-lock-gentoo.patch
	epatch "${FILESDIR}"/${PV}-gentoo.patch
	epatch "${FILESDIR}"/clisp-tests-gentoo.patch
}

src_install() {
	common-lisp-install *.{lisp,asd} tests/*.lisp
	common-lisp-symlink-asdf
	dodoc ChangeLog NEWS README VERSION
}
