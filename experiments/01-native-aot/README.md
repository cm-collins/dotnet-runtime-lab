# Native AOT experiment

This directory contains the runnable workload and verification script. The conceptual guide is in [`../../docs/native-aot.md`](../../docs/native-aot.md).

## Run it

From this directory:

```bash
./verify.sh
```

The script runs the workload through the JIT, publishes the same project with Native AOT, runs the native executable directly, and validates its ELF metadata.

The terminal ends with a compact summary. A detailed Markdown report is generated at:

```text
artifacts/native-aot-evidence.md
```

Generated build output and evidence are ignored by Git. Re-run the script whenever the source, SDK, runtime identifier, or machine changes.
