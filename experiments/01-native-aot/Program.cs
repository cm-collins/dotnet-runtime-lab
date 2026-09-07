using System.Diagnostics;

Console.WriteLine("=== .NET Native AOT Experiment ===");
Console.WriteLine();

var start = Stopwatch.GetTimestamp();
var result = Workload.SumOfSquares(Workload.DefaultIterations);
var elapsed = Stopwatch.GetElapsedTime(start);
var elapsedNanoseconds = elapsed.Ticks * (1_000_000_000L / TimeSpan.TicksPerSecond);

Console.WriteLine($"Result: {result}");
Console.WriteLine($"Elapsed ticks: {elapsed.Ticks}");
Console.WriteLine($"Elapsed nanoseconds: {elapsedNanoseconds}");
Console.WriteLine($"Execution time: {elapsed.TotalMilliseconds:F3} ms");
