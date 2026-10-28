#!/bin/bash
set -euo pipefail

GLAB_VERSION=1.125.0
GLAB_SHA256=c7325f14e408be26fcc1ba5f7a7f71f02c1a20aa3ac6018a57fb04901ea5549a
GH_PR_REVIEW_VERSION=v1.6.2
GH_PR_REVIEW_SHA256=2b7d4f2416f195e98010cb3e2b5684b285808e62864f89dea8497dbe691d7ed0

bindir=$HOME/.local/bin
optdir=$HOME/.local/opt

die() {
	echo "tools.sh: $*" >&2
	exit 1
}

install_glab() {
	local dest=$optdir/glab-$GLAB_VERSION
	local tarball=glab_${GLAB_VERSION}_linux_amd64.tar.gz
	local tmp

	if [ ! -x "$dest/bin/glab" ]; then
		tmp=$(mktemp -d)
		curl -sSfL -o "$tmp/$tarball" \
			"https://gitlab.com/gitlab-org/cli/-/releases/v$GLAB_VERSION/downloads/$tarball"
		if ! echo "$GLAB_SHA256  $tmp/$tarball" | sha256sum -c --quiet; then
			rm -rf "$tmp"
			die "$tarball: wrong sha256"
		fi
		mkdir -p "$dest"
		tar -xzf "$tmp/$tarball" -C "$dest" bin/glab
		rm -rf "$tmp"
	fi
	mkdir -p "$bindir"
	ln -sfn "$dest/bin/glab" "$bindir/glab"
}

install_gh_pr_review() {
	local bin=${XDG_DATA_HOME:-$HOME/.local/share}/gh/extensions/gh-pr-review/gh-pr-review

	if [ -f "$bin" ] && echo "$GH_PR_REVIEW_SHA256  $bin" | sha256sum -c --quiet 2>/dev/null; then
		return
	fi
	if [ -e "$bin" ]; then
		gh extension remove pr-review
	fi
	gh extension install agynio/gh-pr-review --pin "$GH_PR_REVIEW_VERSION"
	if ! echo "$GH_PR_REVIEW_SHA256  $bin" | sha256sum -c --quiet; then
		gh extension remove pr-review
		die "gh-pr-review: wrong sha256, removed it again"
	fi
}

login() {
	local tool=$1 host=$2 how=$3
	if "$tool" auth status --hostname "$host" >/dev/null 2>&1; then
		return
	fi
	if [ ! -t 0 ]; then
		echo "tools.sh: $tool is not logged in to $host, run: $tool auth login --hostname $host $how --git-protocol ssh" >&2
		return
	fi
	"$tool" auth login --hostname "$host" "$how" --git-protocol ssh
}

[ "$(uname -sm)" = "Linux x86_64" ] || die "only Linux x86_64 is supported"
for tool in curl sha256sum tar gh; do
	command -v "$tool" >/dev/null || die "needs $tool"
done
install_glab
login glab gitlab.com --device
login gh github.com --web
install_gh_pr_review
