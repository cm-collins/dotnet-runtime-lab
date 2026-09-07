#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project="$script_dir/02-json-source-generation.csproj"
publish_dir="$script_dir/bin/Release/net10.0/linux-x64/publish"
binary="$publish_dir/02-json-source-generation"

dotnet publish "$project" \
  --configuration Release \
  --runtime linux-x64 \
  --self-contained true \
  -p:PublishAot=true \
  >/dev/null

test -x "$binary"
output="$($binary)"
grep -q '"Mode":"native-aot"' <<<"$output"
grep -q '"Iterations":1000000' <<<"$output"
grep -q '"Result":333332833333500000' <<<"$output"
grep -q 'ELF 64-bit.*executable' <<<"$(file "$binary")"

printf '%s\n' "$output"
printf 'Source-generated JSON AOT example passed.\n'
