# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit common-lisp-3 git-r3

DESCRIPTION="ESRAP -- a packrat parser generator for Common Lisp"
HOMEPAGE="https://github.com/nikodemus/esrap
	www.cliki.net/esrap"
EGIT_REPO_URI="git://github.com/nikodemus/${PN}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND="dev-lisp/alexandria
	dev-lisp/eos"
