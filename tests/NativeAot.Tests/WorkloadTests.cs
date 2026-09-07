using Xunit;

namespace NativeAot.Tests;

public class WorkloadTests
{
    [Theory]
    [InlineData(0, 0)]
    [InlineData(1, 0)]
    [InlineData(2, 1)]
    [InlineData(5, 30)]
    public void SumOfSquares_returns_expected_values(int iterations, long expected)
    {
        Assert.Equal(expected, Workload.SumOfSquares(iterations));
    }

    [Fact]
    public void SumOfSquares_matches_experiment_baseline()
    {
        Assert.Equal(Workload.ExpectedResult, Workload.SumOfSquares(Workload.DefaultIterations));
    }

    [Fact]
    public void SumOfSquares_rejects_negative_iterations()
    {
        Assert.Throws<ArgumentOutOfRangeException>(() => Workload.SumOfSquares(-1));
    }
}
