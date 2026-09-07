# Native AOT and JIT: a learning guide

This guide explains the concepts behind Experiment 01 and how to read its output. Start with the experiment runbook, then return here when a command or result is unfamiliar.

## The short version

| Question | JIT | Native AOT |
| --- | --- | --- |
| When is application code compiled to machine code? | During startup and execution | During publish |
| What do you launch? | Usually a DLL through the dotnet host | A platform-specific executable |
| Is the .NET runtime needed on the target? | Yes, unless published self-contained | The .NET runtime is included in the executable |
| Can the program depend on the OS? | Yes | Yes; self-contained does not mean OS-independent |
| What usually improves? | Flexibility and dynamic runtime behavior | Startup and deployment shape |
| What usually costs more? | Startup JIT work | Publish time and AOT compatibility constraints |

These are tendencies, not guarantees. Application shape and workload determine the measured result.

## From source to execution

~~~mermaid
flowchart TD
    cs[C# source] --> roslyn[Roslyn compiler]
    roslyn --> il[IL and metadata]
    il --> decision{Execution strategy}
    decision -->|JIT| load[dotnet loads the assembly]
    load --> compile[JIT compiles methods as needed]
    compile --> memory[Machine code in process memory]
    decision -->|Native AOT| publish[dotnet publish]
    publish --> analysis[Trimming and AOT analysis]
    analysis --> link[Native code plus runtime components]
    link --> elf[ELF executable on Linux]
~~~

### What IL is

IL (Intermediate Language) is CPU-independent code stored in a .NET assembly. It is not the final x86-64 instructions executed by the processor. Metadata travels with it so the runtime can resolve types, methods, and other program information.

### What the JIT does

The Just-In-Time compiler translates IL methods into machine code while the process runs. This allows runtime feedback and dynamic features, but the process may spend startup time compiling code before useful work completes. The JIT can also optimize based on the current machine and observed execution.

### What Native AOT does

Native AOT performs compilation and linking during publish. The output contains native code and the runtime pieces needed by the application. There is no normal JIT phase for the application on startup, but AOT analysis must know what code and metadata may be needed.

## Reading the experiment

The workload computes:

~~~text
sum(i × i) for i = 0 through 999,999
expected result: 333332833333500000
~~~

The result check matters because a fast program that computes the wrong value is not a useful benchmark. The verifier runs the same source through both paths and rejects either output if the expected result is absent.

## What each output line means

| Output or evidence | Meaning | What it proves |
| --- | --- | --- |
| JIT correctness: PASS | The managed run printed the expected sum | The baseline workload is correct |
| Native AOT correctness: PASS | The published executable printed the same sum | AOT preserved this workload’s behavior |
| ELF 64-bit executable | Linux identifies the file as an ELF executable | It is not merely a DLL being launched by dotnet |
| Class: ELF64 | ELF header uses 64-bit addresses and values | The file is a 64-bit Linux binary |
| Machine: Advanced Micro Devices X86-64 | Header target is x86-64 | It matches the linux-x64 runtime identifier |
| Type: DYN | Linux PIE executable format | It is a dynamically loadable native executable |
| libc.so.6 and ld-linux | The process uses standard Linux runtime libraries | Self-contained still has operating-system dependencies |
| Execution time from the program | Time around the arithmetic loop | Workload timing only; not complete process startup |
| JIT command time in the report | Wall time around dotnet run | Includes process startup and command overhead |
| Native publish time in the report | Wall time around dotnet publish | Build cost, not application runtime |

The report deliberately labels these timings differently. Comparing the program’s Execution time is not the same as comparing cold-start time.

## What Native AOT does not prove

Seeing an ELF file does not prove that AOT is faster for every application. This experiment does not yet measure repeated cold starts, peak memory, reflection-heavy code, or a realistic service workload. It proves that this project can be published as a native Linux executable and that the executable returns the expected result.

## Compatibility and trade-offs

| Area | JIT | Native AOT |
| --- | --- | --- |
| Reflection | Broad runtime discovery | May require annotations or source generation |
| Dynamic code generation | Generally available | Limited or unsupported in some cases |
| Platform portability | One assembly can target many runtimes | Publish per OS and architecture |
| Startup | Includes runtime/JIT work | Usually less JIT startup work |
| Build pipeline | Simpler compile | Longer publish and native toolchain requirements |
| Diagnostics | Rich runtime inspection | Some runtime assumptions are fixed earlier |

## A disciplined measurement sequence

1. Establish correctness with the expected result.
2. Record dotnet --info, uname -a, runtime identifier, configuration, and commit.
3. Compare artifact format and size.
4. Measure repeated cold and warm starts with a dedicated tool.
5. Measure peak resident memory.
6. Explain differences, including measurement noise and deployment assumptions.

The generated report is evidence for one environment and one commit. Treat it as a reproducible observation, not a universal ranking of JIT and AOT.

## Further experiments

- Compare framework-dependent JIT, self-contained JIT, and Native AOT deployment sizes.
- Repeat startup measurements with hyperfine.
- Capture peak memory with /usr/bin/time -f %M.
- Add reflection and dynamic-code examples to observe AOT analysis warnings.
- Inspect symbols and disassembly with readelf, nm, and objdump.
