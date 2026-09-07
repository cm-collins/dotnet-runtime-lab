# Native AOT experiment

This directory contains the primary JIT versus Native AOT workload. The conceptual material is in [`../../docs/native-aot.md`](../../docs/native-aot.md).

## Run the complete experiment

```bash
./verify.sh
```

The verifier:

1. Runs the xUnit correctness suite.
2. Runs the JIT program repeatedly.
3. Publishes the same project with Native AOT.
4. Runs the native executable repeatedly.
5. Reports median process and workload timings.
6. Validates ELF64, x86-64, PIE, and system dependencies.

Use a different sample count when investigating timing noise:

```bash
RUNS=20 ./verify.sh
```

The detailed report is generated at `artifacts/native-aot-evidence.md`.

## Run correctness tests directly

```bash
dotnet test ../../tests/NativeAot.Tests/NativeAot.Tests.csproj -c Release
```

The tests cover small known sums, the experiment baseline, and invalid negative input.

## What to compare

| Timing | Includes | Use it for |
| --- | --- | --- |
| Process median | Shell launch plus application startup | Startup/deployment observations |
| Workload median | Stopwatch around the calculation | Workload execution observations |
| Publish time | Native code generation and linking | Build-cost observations |

Do not treat one run as a benchmark conclusion. Record the sample count, SDK, OS, architecture, configuration, and commit with any result.
