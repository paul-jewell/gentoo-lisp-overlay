# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Armed Bear Common Lisp is a Common Lisp implementation for the JVM."
HOMEPAGE="http://common-lisp.net/project/armedbear/"
SRC_URI="mirror://sourceforge/armedbear-j/${PN}-src-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="jad"

DEPEND=">=virtual/jdk-1.5"
RDEPEND=">=virtual/jre-1.5
	jad? ( dev-java/jad-bin )"

S="${WORKDIR}"/${PN}-src-${PV}

src_compile() {
	eant abcl.compile || die "Can't compile ABCL"
	eant abcl.jar || die "Can't make ABCL jar archive"
}

src_install() {
	java-pkg_dojar dist/abcl.jar
	java-pkg_dolauncher ${PN} --java_args "-server -Xrs" --main org.armedbear.lisp.Main
	dodoc README || die "Can't install README"
}
