#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project="$script_dir/01-native-aot.csproj"
configuration="${CONFIGURATION:-Release}"
runtime="${RUNTIME:-linux-x64}"
publish_dir="$script_dir/bin/$configuration/net10.0/$runtime/publish"
native_binary="$publish_dir/01-native-aot"
expected_result="333332833333500000"
evidence_dir="$script_dir/artifacts"
report="$evidence_dir/native-aot-evidence.md"
mkdir -p "$evidence_dir"

start_ns="$(date +%s%N)"
jit_output="$(dotnet run --project "$project" --configuration "$configuration")"
end_ns="$(date +%s%N)"
jit_ms="$(( (end_ns - start_ns) / 1000000 ))"
grep -q "Result: $expected_result" <<<"$jit_output"

publish_log="$evidence_dir/publish.log"
start_ns="$(date +%s%N)"
dotnet publish "$project" \
  --configuration "$configuration" \
  --runtime "$runtime" \
  --self-contained true \
  -p:PublishAot=true >"$publish_log"
end_ns="$(date +%s%N)"
publish_ms="$(( (end_ns - start_ns) / 1000000 ))"

test -x "$native_binary"
aot_output="$("$native_binary")"
grep -q "Result: $expected_result" <<<"$aot_output"

file_output="$(file "$native_binary")"
grep -q 'ELF 64-bit.*executable' <<<"$file_output"
header_output="$(readelf -h "$native_binary")"
grep -q 'Class:[[:space:]]*ELF64' <<<"$header_output"
grep -q 'Machine:[[:space:]]*Advanced Micro Devices X86-64' <<<"$header_output"
grep -q 'Type:[[:space:]]*DYN' <<<"$header_output"
header_summary="$(grep -E 'Class:|Machine:|Type:' <<<"$header_output")"
dependencies="$(ldd "$native_binary" || true)"
binary_bytes="$(stat -c '%s' "$native_binary")"
binary_size="$(du -h "$native_binary" | cut -f1)"

cat >"$report" <<EOF
# Native AOT verification evidence

Generated: $(date -u +'%Y-%m-%dT%H:%M:%SZ')
Commit: $(git -C "$script_dir/../.." rev-parse HEAD 2>/dev/null || printf 'unavailable')
Runtime: $runtime
Configuration: $configuration

## Result summary

| Check | Result |
| --- | --- |
| JIT correctness | PASS — expected result $expected_result |
| Native AOT correctness | PASS — expected result $expected_result |
| Native executable | PASS — ELF64 x86-64 PIE |
| Direct executable size | $binary_size ($binary_bytes bytes) |
| JIT command time | ${jit_ms} ms (includes process startup) |
| Native publish time | ${publish_ms} ms |

## Program output

### JIT

~~~text
$jit_output
~~~

### Native AOT

~~~text
$aot_output
~~~

## ELF metadata

~~~text
$file_output
$header_summary
~~~

## System dependencies

~~~text
$dependencies
~~~

## Reproduce

Run verify.sh from this directory.
EOF

printf '| Check | Result |\n| --- | --- |\n| JIT correctness | PASS |\n| Native AOT correctness | PASS |\n| ELF64 x86-64 executable | PASS |\n| Native binary | %s (%s bytes) |\n| Evidence report | %s |\n' "$binary_size" "$binary_bytes" "$report"
