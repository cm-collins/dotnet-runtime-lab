public static class Workload
{
    public const int DefaultIterations = 1_000_000;
    public const long ExpectedResult = 333332833333500000;

    public static long SumOfSquares(int iterations)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(iterations);

        long result = 0;

        for (var value = 0; value < iterations; value++)
        {
            checked
            {
                result += (long)value * value;
            }
        }

        return result;
    }
}
