
# Native AOT — Experiment 01

This experiment explores **Native Ahead-of-Time (AOT) compilation in .NET**.

The goal is to understand what happens when a .NET application is compiled into a native executable before it runs, and how this differs from the traditional JIT-based execution model.

## Objective

Build a small .NET application and compile it using **Native AOT**.

We will then use the same application to investigate:

- How Native AOT compilation works
- What gets produced at build time
- The resulting native executable
- Startup behavior
- Memory usage
- Binary size
- Runtime dependencies
- How Native AOT differs from JIT
- The trade-offs involved in using Native AOT



## Experiment Structure

```text
01-native-aot/
├── 01-native-aot.csproj
├── Program.cs
└── README.md
```



## Environment

The experiment runs inside the repository's Dev Container.

Current environment:

- .NET SDK 10.0.400
- .NET Runtime 10.0.11
- Ubuntu 24.04
- Linux x64
- Clang 18.1.3
- GCC 13.3.0



## Native AOT Build

The application can be published using:

```bash
dotnet publish \
  -c Release \
  -r linux-x64 \
  -p:PublishAot=true \
  --self-contained true
```

The resulting files are generated under:

```text
bin/Release/net10.0/linux-x64/publish/
```

A successful Native AOT build produces a native executable:

```text
01-native-aot
```

along with debugging information:

```text
01-native-aot.dbg
```



## Execution

Run the generated native executable directly:

```bash
./bin/Release/net10.0/linux-x64/publish/01-native-aot
```

The executable does not require the .NET runtime to be installed separately on the target system.

## What We Are Investigating

The first stage of this experiment establishes that we can successfully transform:

```text
C# Source
    ↓
.NET Compiler
    ↓
IL
    ↓
Native AOT
    ↓
Native Executable
```

The next stage will compare this with the traditional JIT execution model:

```text
                    C# Source
                        ↓
                       IL
                    ↙     ↘
                  JIT      AOT
                   ↓        ↓
             Native Code  Native Code
```

We will use the **same application and workload** for both approaches wherever possible.

## Measurements

We will eventually record:


| Metric               | JIT | Native AOT |
| -------------------- | --- | ---------- |
| Build time           | TBD | TBD        |
| Binary size          | TBD | TBD        |
| Startup time         | TBD | TBD        |
| Memory usage         | TBD | TBD        |
| Execution time       | TBD | TBD        |
| Runtime dependencies | TBD | TBD        |


These measurements will help us understand the practical differences rather than relying only on theoretical explanations.

## Questions

This experiment is intended to answer questions such as:

1. What exactly does Native AOT produce?
2. Does Native AOT eliminate the need for JIT?
3. How does startup time change?
4. How does memory consumption change?
5. Why can Native AOT produce a self-contained native executable?
6. What .NET features behave differently under Native AOT?
7. When would Native AOT be a better choice than JIT?
8. What trade-offs are introduced by AOT compilation?



## Current Status

- [x] Dev Container configured
- [x] .NET 10 SDK available
- [x] Native AOT toolchain verified
- [x] Basic console application created
- [x] Native AOT build successful
- [x] Native executable generated
- [ ] Establish JIT baseline
- [ ] Establish AOT baseline
- [ ] Benchmark startup
- [ ] Benchmark memory usage
- [ ] Compare binary sizes
- [ ] Investigate generated native code
- [ ] Document findings



## Key Principle

This repository is an **engineering lab**, not just a collection of examples.

Each experiment should follow:

```text
Question
   ↓
Hypothesis
   ↓
Implementation
   ↓
Measurement
   ↓
Observation
   ↓
Explanation
   ↓
Conclusion
```

The purpose is to understand **why .NET behaves the way it does**, not simply how to use a particular feature.
