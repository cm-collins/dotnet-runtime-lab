# Native AOT experiment guide

## At a glance

| Mode | Compilation point | Launch artifact | Main trade-off |
| --- | --- | --- | --- |
| JIT | During application startup and execution | Managed DLL launched by `dotnet` | Flexible, but pays runtime compilation cost |
| Native AOT | During `dotnet publish` | Platform-specific native executable | Fast startup and simpler deployment, but less runtime dynamism |

This experiment runs the same CPU-bound workload in both modes. It is a teaching baseline, not a production benchmark.

## Question and hypothesis

**Question:** What changes when this program is published with Native AOT instead of run through the JIT?

**Hypothesis:** AOT should produce a directly executable ELF file and avoid JIT work at startup. It may improve startup and packaging, while increasing publish time and reducing support for reflection or runtime code generation.

## Workload and correctness

`Program.cs` computes the sum of squares from `0` through `999,999`. The expected result is:

```text
333332833333500000
```

`verify.sh` checks this result in both modes so a performance comparison cannot silently compare different workloads.

## Reproduce it

From this directory:

```bash
./verify.sh
```

The script performs these checks:

| Stage | Evidence |
| --- | --- |
| JIT run | `dotnet run --configuration Release` produces the expected result |
| AOT publish | `dotnet publish --runtime linux-x64 --self-contained true -p:PublishAot=true` succeeds |
| Native format | `file` reports an ELF executable |
| Target architecture | `readelf -h` reports x86-64 |
| Direct launch | The published file runs without invoking `dotnet` |
| System linkage | `ldd` shows operating-system libraries used by the executable |

Native AOT is self-contained with respect to the .NET runtime, but it can still depend on operating-system libraries such as libc.

## Measurement plan

| Metric | JIT | Native AOT | Suggested evidence |
| --- | --- | --- | --- |
| Build time | — | — | `/usr/bin/time -v dotnet ...` |
| Artifact size | DLL and runtime deployment | Native executable and dependencies | `du -h`, `stat -c %s` |
| Startup | — | — | `hyperfine` or repeated `/usr/bin/time` runs |
| Workload time | Printed by program | Printed by program | Program output |
| Peak memory | — | — | `/usr/bin/time -f %M` |
| Dependencies | .NET runtime files | OS libraries | `ldd` and publish directory listing |

Always record `dotnet --info`, `uname -a`, the git commit, configuration, runtime identifier, and number of repetitions. One run is not enough for a performance conclusion because CPU frequency, filesystem cache, and background load introduce noise.

## Interpreting observations

| Observation | Interpretation |
| --- | --- |
| AOT runs as `./01-native-aot` | The artifact is directly executable native code |
| AOT publish is slower | Native code and runtime pieces are produced ahead of execution |
| AOT has a larger deployment | More runtime code is bundled into the application |
| `ldd` lists libc | Self-contained does not mean independent of the OS |
| Reflection or dynamic code needs annotations | AOT must discover required code and metadata at build time |

## Evidence checklist

- [x] Shared workload and expected-result check
- [x] JIT baseline
- [x] Native AOT publish
- [x] ELF, architecture, and linkage inspection
- [ ] Repeated startup benchmark
- [ ] Peak-memory comparison
- [ ] Binary-size report
- [ ] Native disassembly and symbol inspection
- [ ] Reflection/trimming/dynamic-code example

The root [root dev container](../.devcontainer/devcontainer.json) is the only development-container configuration for the repository.
