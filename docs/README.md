# Runtime lab notes

This folder contains the explanatory material for the runtime experiments. Runnable code stays beside each experiment under `experiments/`.

| Document | Topic |
| --- | --- |
| [Native AOT and JIT](native-aot.md) | Compilation paths, output interpretation, and trade-offs |

## Experiment path

| Experiment | Focus | Start here |
| --- | --- | --- |
| 01 Native AOT | Repeated JIT/AOT timing, ELF evidence, and correctness tests | [Runbook](../experiments/01-native-aot/README.md) |
| 02 JSON source generation | AOT-friendly serialization metadata | [Example](../experiments/02-json-source-generation/README.md) |

Generated reports belong in ignored `artifacts/` directories. They record observations for one machine and commit; they are not universal performance claims.
