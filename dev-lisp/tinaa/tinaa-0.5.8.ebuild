# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit common-lisp-2 eutils

DESCRIPTION="Tinaa is a flexible and general purpose Lisp documentation system."
HOMEPAGE="http://common-lisp.net/project/tinaa"
SRC_URI="http://common-lisp.net/~sionescu/files/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

DEPEND=">=dev-lisp/defsystem-compatibility-0.1.2
		dev-lisp/metatilities
		dev-lisp/lml2
		dev-lisp/trivial-shell
		dev-lisp/cl-graph
		dev-lisp/anaphora
		dev-lisp/cl-markdown"

src_install() {
	common-lisp-install *.asd dev/{*.lisp,tinaa.css} unit-tests
	common-lisp-symlink-asdf
	dodoc RELNOTES
}
