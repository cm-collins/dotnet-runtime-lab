# .NET Runtime Lab

An experiment-driven guide to how .NET programs become executable code.

This repository is written for people learning the runtime, not only for people who already know .NET. Every experiment should answer a question, make a prediction, run a controlled test, collect evidence, and explain what the evidence does and does not prove.

## Start here

| Step | What to do |
| --- | --- |
| 1 | Open the repository in the root Dev Container |
| 2 | Read the Native AOT learning guide in docs/native-aot.md |
| 3 | Run Experiment 01 |
| 4 | Inspect the generated evidence report under experiments/01-native-aot/artifacts/ |
| 5 | Compare the observed output with the explanation tables |

From the repository root:

~~~bash
cd experiments/01-native-aot
./verify.sh
~~~

## The two execution paths

~~~mermaid
flowchart LR
    source[C# source] --> compiler[Roslyn compiler]
    compiler --> il[IL plus metadata]
    il --> jit[JIT at startup]
    jit --> jitCode[Native machine code in memory]
    il --> aot[Native AOT publish]
    aot --> binary[Native executable on disk]
~~~

Both paths begin with C# and IL. The important difference is when native machine code is produced: while the application is running for JIT, or during publishing for Native AOT.

## What this lab covers

- C# to IL and machine-code execution
- JIT compilation and startup work
- Native AOT publishing and executable formats
- Garbage collection, allocation, and memory
- Binary size, dependencies, and deployment
- Reproducible measurements and performance caveats

## Repository map

~~~text
.
├── .devcontainer/             Shared development environment
├── docs/                      Explanatory learning material
├── experiments/
│   └── 01-native-aot/         Runnable JIT vs Native AOT experiment
└── README.md                  This orientation guide
~~~

Generated files belong in ignored bin/, obj/, publish/, and artifacts/ directories. Source documents and scripts are committed; machine-specific measurements are not treated as universal facts.

## Working principles

| Principle | Meaning |
| --- | --- |
| Same workload | JIT and AOT must execute equivalent code |
| Correctness first | Check the result before comparing speed |
| Evidence over labels | Confirm “native” with file format and headers |
| Repeat measurements | One timing is an observation, not a conclusion |
| Explain limits | Record OS, SDK, runtime, architecture, and commit |

See docs/README.md for the learning path.
