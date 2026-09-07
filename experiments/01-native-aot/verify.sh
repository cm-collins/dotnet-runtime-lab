#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project="$script_dir/01-native-aot.csproj"
configuration="${CONFIGURATION:-Release}"
runtime="${RUNTIME:-linux-x64}"
publish_dir="$script_dir/bin/$configuration/net10.0/$runtime/publish"
native_binary="$publish_dir/01-native-aot"
expected_result="333332833333500000"

printf '== JIT baseline ==\n'
jit_output="$(dotnet run --project "$project" --configuration "$configuration")"
printf '%s\n' "$jit_output"
grep -q "Result: $expected_result" <<<"$jit_output"

printf '\n== Native AOT publish ==\n'
dotnet publish "$project" \
  --configuration "$configuration" \
  --runtime "$runtime" \
  --self-contained true \
  -p:PublishAot=true

test -x "$native_binary"
aot_output="$("$native_binary")"
printf '%s\n' "$aot_output"
grep -q "Result: $expected_result" <<<"$aot_output"

printf '\n== Native evidence ==\n'
file_output="$(file "$native_binary")"
grep -q 'ELF 64-bit.*executable' <<<"$file_output"
printf '%s\n' "$file_output"

header_output="$(readelf -h "$native_binary")"
grep -q 'Class:[[:space:]]*ELF64' <<<"$header_output"
grep -q 'Machine:[[:space:]]*Advanced Micro Devices X86-64' <<<"$header_output"
grep -q 'Type:[[:space:]]*DYN' <<<"$header_output"
grep -E 'Class:|Machine:|Type:' <<<"$header_output"
printf '\nDynamic libraries (system dependencies):\n'
ldd "$native_binary" || true

printf '\nVerification passed: JIT and Native AOT produced the expected result, and the AOT output is executable.\n'
