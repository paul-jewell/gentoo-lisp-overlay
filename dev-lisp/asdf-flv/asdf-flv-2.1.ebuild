# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit common-lisp-3

MY_PV="version-${PV}"

DESCRIPTION="ASDF extension to provide support for file-local variables"
HOMEPAGE="https://www.lrde.epita.fr/~didier/software/lisp/misc.php#asdf-flv
	http://www.cliki.net/asdf-flv"
SRC_URI="https://github.com/didierverna/${PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

# LICENSE.invalid while looking for it
LICENSE="GNU_All_Permissive"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	mv "net.didierverna.${PN}.asd" "${PN}.asd" || die
	sed -i -e 's/net\.didierverna\.//g' "${PN}.asd" "${PN}.lisp" "package.lisp" || die
	default
}
