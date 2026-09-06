using System.Diagnostics;

Console.WriteLine("=== .NET Native AOT Experiment ===");
Console.WriteLine();

var stopwatch = Stopwatch.StartNew();

const int iterations = 10_000_000;

long result = 0;

for (var i = 0; i < iterations; i++)
{
    result += Calculate(i);
}

stopwatch.Stop();

Console.WriteLine($"Result: {result}");
Console.WriteLine($"Execution time: {stopwatch.ElapsedMilliseconds} ms");

static long Calculate(int value)dotnet publish \
  -c Release \
  -r linux-x64 \
  -p:PublishAot=true \
  --self-contained true
{
    return (long)value * value;
}