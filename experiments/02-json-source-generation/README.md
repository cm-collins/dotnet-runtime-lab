# Experiment 02: JSON source generation with Native AOT

This example serializes a small report using `System.Text.Json` source generation. The generator creates the serialization metadata at build time, which makes the example friendly to trimming and Native AOT.

## Run it

```bash
./verify.sh
```

Expected output:

```json
{"Mode":"native-aot","Iterations":1000000,"Result":333332833333500000}
```

The verifier publishes a self-contained Linux Native AOT executable, launches it directly, checks the JSON fields, and confirms the output is ELF64.

## Why this matters

Reflection-based serializers discover types and properties at runtime. Trimming and Native AOT may remove code that the runtime cannot prove will be needed. Source generation moves that metadata discovery to build time, making the dependency explicit and analyzable.
