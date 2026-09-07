using System.Text.Json;
using System.Text.Json.Serialization;

var report = new WorkloadReport("native-aot", 1_000_000, 333332833333500000);
var json = JsonSerializer.Serialize(report, JsonContext.Default.WorkloadReport);

Console.WriteLine(json);

public sealed record WorkloadReport(string Mode, int Iterations, long Result);

[JsonSerializable(typeof(WorkloadReport))]
internal partial class JsonContext : JsonSerializerContext;
