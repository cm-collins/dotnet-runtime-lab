#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$script_dir/../.." && pwd)"
project="$script_dir/01-native-aot.csproj"
test_project="$repo_dir/tests/NativeAot.Tests/NativeAot.Tests.csproj"
configuration="${CONFIGURATION:-Release}"
runtime="${RUNTIME:-linux-x64}"
runs="${RUNS:-5}"
publish_dir="$script_dir/bin/$configuration/net10.0/$runtime/publish"
native_binary="$publish_dir/01-native-aot"
expected_result="333332833333500000"
evidence_dir="$script_dir/artifacts"
report="$evidence_dir/native-aot-evidence.md"
mkdir -p "$evidence_dir"

if ! [[ "$runs" =~ ^[1-9][0-9]*$ ]]; then
  printf 'RUNS must be a positive integer (received: %s)\n' "$runs" >&2
  exit 2
fi

printf 'Running correctness tests...\n'
dotnet test "$test_project" --configuration "$configuration" --nologo >"$evidence_dir/test.log"

stats() {
  printf '%s\n' "$@" | sort -n | awk '
    { values[NR] = $1 }
    END {
      middle = (NR + 1) / 2
      if (NR % 2) print values[middle]
      else print (values[NR / 2] + values[NR / 2 + 1]) / 2
    }'
}

jit_process_ns=()
jit_workload_ns=()
for ((run = 1; run <= runs; run++)); do
  start_ns="$(date +%s%N)"
  jit_output="$(dotnet run --project "$project" --configuration "$configuration" --no-restore)"
  end_ns="$(date +%s%N)"
  grep -q "Result: $expected_result" <<<"$jit_output"
  jit_process_ns+=( "$((end_ns - start_ns))" )
  jit_workload_ns+=( "$(awk -F': ' '/Elapsed nanoseconds:/ { print $2 }' <<<"$jit_output")" )
done

publish_log="$evidence_dir/publish.log"
publish_start_ns="$(date +%s%N)"
dotnet publish "$project" \
  --configuration "$configuration" \
  --runtime "$runtime" \
  --self-contained true \
  -p:PublishAot=true >"$publish_log"
publish_end_ns="$(date +%s%N)"
publish_ns="$((publish_end_ns - publish_start_ns))"

test -x "$native_binary"
aot_process_ns=()
aot_workload_ns=()
for ((run = 1; run <= runs; run++)); do
  start_ns="$(date +%s%N)"
  aot_output="$("$native_binary")"
  end_ns="$(date +%s%N)"
  grep -q "Result: $expected_result" <<<"$aot_output"
  aot_process_ns+=( "$((end_ns - start_ns))" )
  aot_workload_ns+=( "$(awk -F': ' '/Elapsed nanoseconds:/ { print $2 }' <<<"$aot_output")" )
done

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

jit_process_median_ns="$(stats "${jit_process_ns[@]}")"
jit_workload_median_ns="$(stats "${jit_workload_ns[@]}")"
aot_process_median_ns="$(stats "${aot_process_ns[@]}")"
aot_workload_median_ns="$(stats "${aot_workload_ns[@]}")"

cat >"$report" <<EOF
# Native AOT verification evidence

Generated: $(date -u +'%Y-%m-%dT%H:%M:%SZ')
Commit: $(git -C "$repo_dir" rev-parse HEAD 2>/dev/null || printf 'unavailable')
Runtime: $runtime
Configuration: $configuration
Samples per mode: $runs

## Result summary

| Check | Result |
| --- | --- |
| Correctness tests | PASS |
| JIT correctness | PASS — expected result $expected_result |
| Native AOT correctness | PASS — expected result $expected_result |
| Native executable | PASS — ELF64 x86-64 PIE |
| Direct executable size | $binary_size ($binary_bytes bytes) |
| JIT process median | ${jit_process_median_ns} ns |
| Native process median | ${aot_process_median_ns} ns |
| JIT workload median | ${jit_workload_median_ns} ns |
| Native workload median | ${aot_workload_median_ns} ns |
| Native publish time | $((publish_ns / 1000000)) ms |

Process timing includes launching the command. Workload timing comes from Stopwatch inside the application.

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

Run RUNS=$runs ./verify.sh from the experiment directory.
EOF

printf '| Check | Result |\n| --- | --- |\n| Correctness tests | PASS |\n| JIT samples | %s (median process: %s ns) |\n| Native AOT samples | %s (median process: %s ns) |\n| ELF64 x86-64 executable | PASS |\n| Native binary | %s (%s bytes) |\n| Evidence report | %s |\n' \
  "$runs" "$jit_process_median_ns" "$runs" "$aot_process_median_ns" "$binary_size" "$binary_bytes" "$report"
