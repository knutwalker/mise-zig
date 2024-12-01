#!/usr/bin/env bash

set -euo pipefail

ZIG_LIST="https://ziglang.org/download/index.json"
MACH_LIST="https://machengine.org/zig/index.json"
TOOL_NAME="zig"
TOOL_TEST="zig version"

fail() {
	printf "mise-%s: %s\n" "$TOOL_NAME" "$*" 1>&2
	exit 1
}

curl_opts=(-fsSL)

get_os() {
	case "$OSTYPE" in
	darwin*) printf "macos\n" ;;
	freebsd*) printf "freebsd\n" ;;
	linux*) printf "linux\n" ;;
	*) fail "Unsupported platform" ;;
	esac
}

get_arch() {
	case "$(uname -m)" in
	aarch64* | arm64) printf "aarch64\n" ;;
	armv7*) printf "armv7a\n" ;;
	i686*) printf "i386\n" ;;
	riscv64*) printf "riscv64\n" ;;
	x86_64*) printf "x86_64\n" ;;
	*) fail "Unsupported architecture" ;;
	esac
}

get_target() {
	printf "%s-%s\n" "$(get_arch)" "$(get_os)"
}

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

# shellcheck disable=SC2016 # $TARGET, $REPO, and $DOWN are arguments passed in from jq
jqVersionParam='to_entries|map(select((.value | (.[$TARGET]) | (.[$DOWN]) != null) and ($REPO != "Mach" or .key != "master")) | .value.version // .key)|.[]'
list_all_versions() {
	local zigVersions machVersions
	zigVersions=$(curl "${curl_opts[@]}" "$ZIG_LIST" | jq -r --arg TARGET "$(get_target)" --arg DOWN "tarball" --arg REPO "Zig" "$jqVersionParam")
	machVersions=$(curl "${curl_opts[@]}" "$MACH_LIST" | jq -r --arg TARGET "$(get_target)" --arg DOWN "tarball" --arg REPO "Mach" "$jqVersionParam")
	printf "%s\n%s\n" "$zigVersions" "$machVersions" | sort_versions | uniq
}

jqAliasParam='to_entries|map(select(.value.version != null) | "\(if .key == "master" then "nightly" else .key end) \(.value.version)")|.[]'
list_aliases() {
	local zigAliases machAliases
	zigAliases=$(curl "${curl_opts[@]}" "$ZIG_LIST" | jq -r "$jqAliasParam")
	machAliases=$(curl "${curl_opts[@]}" "$MACH_LIST" | jq -r "$jqAliasParam" | grep -v '^nightly')
	printf "%s\n%s\n" "$zigAliases" "$machAliases"
}

# shellcheck disable=SC2016 # $VERSION, $TARGET, and $DOWN are arguments passed in from jq
jqUrlParam='to_entries|map(select(.value.version == $VERSION) | (.value | (.[$TARGET]) | (.[$DOWN])))|.[:1]|.[]'
get_url() {
	local version machTarball zigTarball
	version=$1
	machTarball=$(curl "${curl_opts[@]}" "$MACH_LIST" | jq -r --arg TARGET "$(get_target)" --arg VERSION "$version" --arg DOWN "tarball" "$jqUrlParam")
	if [ -n "$machTarball" ]; then
		printf "%s\n" "$machTarball"
	else
		zigTarball=$(curl "${curl_opts[@]}" "$ZIG_LIST" | jq -r --arg TARGET "$(get_target)" --arg VERSION "$version" --arg DOWN "tarball" "$jqUrlParam")
		printf "%s\n" "$zigTarball"
	fi
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"

	url=$(get_url "$version")

	printf "* Downloading %s release %s...\n" "$TOOL_NAME" "$version"
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "mise-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		printf "%s %s installation was successful!\n" "$TOOL_NAME" "$version"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}

