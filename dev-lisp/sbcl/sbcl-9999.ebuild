# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit git multilib eutils flag-o-matic

#same order as http://www.sbcl.org/platform-table.html
BV_X86=1.0.37
BV_AMD64=1.0.37
BV_PPC=1.0.28
BV_SPARC=1.0.28
BV_ALPHA=1.0.28
BV_MIPS=1.0.23
BV_MIPSEL=1.0.28

DESCRIPTION="Steel Bank Common Lisp (SBCL) is an implementation of ANSI Common Lisp."
HOMEPAGE="http://sbcl.sourceforge.net/"
EGIT_REPO_URI="git://git.boinkor.net/sbcl.git"
SRC_URI="x86? ( mirror://sourceforge/sbcl/${PN}-${BV_X86}-x86-linux-binary.tar.bz2 )
	amd64? ( mirror://sourceforge/sbcl/${PN}-${BV_AMD64}-x86-64-linux-binary.tar.bz2 )
	ppc? ( mirror://sourceforge/sbcl/${PN}-${BV_PPC}-powerpc-linux-binary.tar.bz2 )
	sparc? ( mirror://sourceforge/sbcl/${PN}-${BV_SPARC}-sparc-linux-binary.tar.bz2 )
	alpha? ( mirror://sourceforge/sbcl/${PN}-${BV_ALPHA}-alpha-linux-binary.tar.bz2 )
	mips? ( !cobalt? ( mirror://sourceforge/sbcl/${PN}-${BV_MIPS}-mips-linux-binary.tar.bz2 ) )
	mips? ( cobalt? ( mirror://sourceforge/sbcl/${PN}-${BV_MIPSEL}-mipsel-linux-binary.tar.bz2 ) )"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="ldb source +threads +unicode debug doc cobalt"

DEPEND="doc? ( sys-apps/texinfo >=media-gfx/graphviz-2.26.0 )"
RDEPEND="elibc_glibc? ( >=sys-libs/glibc-2.3 || ( <sys-libs/glibc-2.6[nptl] >=sys-libs/glibc-2.6 ) )"
PDEPEND="dev-lisp/gentoo-init"

PROVIDE="virtual/commonlisp"

# Disable warnings about executable stacks, as this won't be fixed soon by upstream
QA_EXECSTACK="usr/bin/sbcl"

CONFIG="${S}/customize-target-features.lisp"
ENVD="${T}/50sbcl"

usep() {
	use ${1} && echo "true" || echo "false"
}

sbcl_feature() {
	echo "$( [[ ${1} == "true" ]] && echo "(enable ${2})" || echo "(disable ${2})")" >> "${CONFIG}"
}

sbcl_apply_features() {
	cat > "${CONFIG}" <<'EOF'
(lambda (list)
  (flet ((enable  (x) (pushnew x list))
		 (disable (x) (setf list (remove x list))))
EOF
	if use x86 || use amd64; then
		sbcl_feature "$(usep threads)" ":sb-thread"
	fi
	sbcl_feature "$(usep ldb)" ":sb-ldb"
	sbcl_feature "false" ":sb-test"
	sbcl_feature "$(usep unicode)" ":sb-unicode"
	sbcl_feature "$(usep debug)" ":sb-xref-for-internals"
	cat >> "${CONFIG}" <<'EOF'
	)
  list)
EOF
	cat "${CONFIG}"
}

src_unpack() {
	unpack ${A}
	mv sbcl-*-linux sbcl-binary
	git_src_unpack
	cd "${S}"
}

src_prepare() {
	git_src_prepare

	epatch "${FILESDIR}"/${PV}-gentoo-fix_build_system.patch
	epatch "${FILESDIR}"/gentoo-fix_install_man.patch
	epatch "${FILESDIR}"/gentoo-fix_linux-os-c.patch

	use source && sed 's%"$(BUILD_ROOT)%$(MODULE).lisp "$(BUILD_ROOT)%' -i contrib/vanilla-module.mk

	# Some shells(such as dash) don't have "time" as builtin
	# and we don't want to DEPEND on sys-process/time
	sed "s,^time ,," -i make.sh
	sed "s,/lib,/$(get_libdir),g" -i install.sh
	sed "s,/usr/local/lib,/usr/$(get_libdir),g" -i src/runtime/runtime.c # #define SBCL_HOME ...

	find . -type f -name .cvsignore -delete
}

src_configure() {
	# customizing SBCL version as per
	# http://sbcl.cvs.sourceforge.net/sbcl/sbcl/doc/PACKAGING-SBCL.txt?view=markup
	echo -e ";;; Auto-generated by Gentoo\n\"gentoo-${PR}\"" > branch-version.lisp-expr

	# applying customizations
	sbcl_apply_features
}

src_compile() {
	local bindir="${WORKDIR}"/sbcl-binary

	strip-unsupported-flags ; filter-flags -fomit-frame-pointer
	append-ldflags -Wl,--no-as-needed # see bug #132992

	# To make the hardened compiler NOT compile with -fPIE -pie
	if gcc-specs-pie ; then
		filter-flags -fPIE
		append-ldflags -nopie
	fi

	# clear the environment to get rid of non-ASCII strings, see bug 174702
	# set HOME for paludis
	env - HOME="${T}" \
		CC="$(tc-getCC)" AS="$(tc-getAS)" LD="$(tc-getLD)" \
		CPPFLAGS="${CPPFLAGS}" CFLAGS="${CFLAGS}" ASFLAGS="${ASFLAGS}" LDFLAGS="${LDFLAGS}" \
		GNUMAKE=make ./make.sh \
		"sh ${bindir}/run-sbcl.sh --no-sysinit --no-userinit --disable-debugger" \
		|| die "make failed"

	# need to set HOME because libpango(used by graphviz) complains about it
	if use doc; then
		env - HOME="${T}" make -C doc/manual info html || die "Cannot build manual"
		env - HOME="${T}" make -C doc/internals info html || die "Cannot build internal docs"
	fi
}

src_test() {
	ewarn "Unfortunately, it is known that some tests fail eg."
	ewarn "run-program.impure.lisp. This is an issue of the upstream's"
	ewarn "development and not of Gentoo's side. Please, before filing"
	ewarn "any bug(s) search for older submissions. Thank you."
	time ( cd tests && sh run-tests.sh )
}

src_install() {
	# install system-wide initfile
	dodir /etc/
	cat > "${D}"/etc/sbclrc <<EOF
;;; The following is required if you want source location functions to
;;; work in SLIME, for example.

(setf (logical-pathname-translations "SYS")
	'(("SYS:SRC;**;*.*.*" #p"/usr/$(get_libdir)/sbcl/src/**/*.*")
	  ("SYS:CONTRIB;**;*.*.*" #p"/usr/$(get_libdir)/sbcl/**/*.*")))

;;; Setup ASDF
(load "/etc/gentoo-init.lisp")
EOF

	# Install documentation
	unset SBCL_HOME
	INSTALL_ROOT="${D}/usr" LIB_DIR="/usr/$(get_libdir)" DOC_DIR="${D}/usr/share/doc/${PF}" \
		sh install.sh || die "install.sh failed"

	# rm empty directories lest paludis complain about this
	find "${D}" -empty -type d -exec rmdir -v {} +

	if use doc; then
		dohtml -r doc/manual/
		doinfo doc/manual/*.info*
		dohtml -r doc/internals/sbcl-internals
		doinfo doc/internals/sbcl-internals.info
		docinto internals-notes && dodoc doc/internals-notes/*
	else
		rm -Rv "${D}/usr/share/doc/${PF}"
	fi

	dodoc BUGS CREDITS INSTALL NEWS OPTIMIZATIONS PRINCIPLES README STYLE TLA TODO

	# install the SBCL source
	if use source; then
		./clean.sh
		cp -av src "${D}/usr/$(get_libdir)/sbcl/"
	fi

	# necessary for running newly-saved images
	echo "SBCL_HOME=/usr/$(get_libdir)/${PN}" > "${ENVD}"
	echo "SBCL_SOURCE_ROOT=/usr/$(get_libdir)/${PN}/src" >> "${ENVD}"
	doenvd "${ENVD}"
}
