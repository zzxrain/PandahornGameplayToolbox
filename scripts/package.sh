#!/bin/bash
# Compatible with the Bash 3.2 and command-line tools shipped with macOS.
set -euo pipefail

fail() { printf 'Packaging failed: %s\n' "$*" >&2; exit 1; }
command -v zip >/dev/null || fail "zip is required"
root=$(cd "$(dirname "$0")/.." && pwd -P)
name=PandahornGameplayToolbox
manifest="$root/$name.toc"
[[ -f "$manifest" && ! -L "$manifest" ]] || fail "Missing or symlinked manifest"
version=$(sed -n 's/^[[:space:]]*## Version:[[:space:]]*//p' "$manifest" | sed 's/[[:space:]]*$//')
[[ "$version" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || fail "Expected one valid ## Version value"

files=("$name.toc")
while IFS= read -r line || [[ -n "$line" ]]; do
    entry=$(printf '%s' "$line" | tr '\\' '/' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    case "$entry" in
        '## IconTexture:'*)
            entry=${entry#'## IconTexture:'}
            entry=$(printf '%s' "$entry" | sed 's/^[[:space:]]*//')
            prefix="Interface/AddOns/$name/"
            [[ "$entry" == "$prefix"* ]] || fail "IconTexture must be inside the addon directory"
            entry=${entry#"$prefix"}
            ;;
        '# Package:'*)
            entry=${entry#'# Package:'}
            entry=$(printf '%s' "$entry" | sed 's/^[[:space:]]*//')
            [[ -n "$entry" ]] || fail "Empty Package resource path"
            ;;
    esac
    case "$entry" in
        ''|\#*) continue ;;
        /*|*:*|..|../*|*/../*|*/..) fail "Invalid manifest path: $entry" ;;
    esac
    [[ -f "$root/$entry" ]] || fail "Missing runtime file: $entry"
    # Reject symlinked files and directories rather than copying external files.
    remaining="$entry"
    current="$root"
    while [[ -n "$remaining" ]]; do
        part=${remaining%%/*}
        current="$current/$part"
        [[ ! -L "$current" ]] || fail "Symlinked runtime path: $entry"
        if [[ "$remaining" == */* ]]; then
            remaining=${remaining#*/}
        else
            remaining=''
        fi
    done
    duplicate=false
    for file in "${files[@]}"; do
        [[ "$file" != "$entry" ]] || duplicate=true
    done
    if [[ "$duplicate" == false ]]; then files+=("$entry"); fi
done < "$manifest"

mkdir -p "$root/dist"
temporary=$(mktemp -d "$root/dist/.package.XXXXXX")
trap 'rm -rf "$temporary"' EXIT
for file in "${files[@]}"; do
    mkdir -p "$temporary/$name/$(dirname "$file")"
    cp "$root/$file" "$temporary/$name/$file"
done
output="$root/dist/$name-$version.zip"
(
    cd "$temporary"
    # Explicit files only; -X removes extra metadata from archive entries.
    COPYFILE_DISABLE=1 zip -q -X "$temporary/package.zip" "${files[@]/#/$name/}"
)
mv -f "$temporary/package.zip" "$output"
printf 'Created %s (%s files)\n' "$output" "${#files[@]}"
