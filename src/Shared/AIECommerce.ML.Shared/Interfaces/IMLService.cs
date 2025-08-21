namespace AIECommerce.ML.Shared.Interfaces;

public interface IMLService
{
    Task<bool> IsHealthyAsync();
    Task<string> GetServiceInfoAsync();
    Task<DateTime> GetLastModelUpdateAsync();
    Task<double> GetModelAccuracyAsync();
}

public interface IMLService<TInput, TOutput> : IMLService
{
    Task<TOutput> PredictAsync(TInput input);
    Task<List<TOutput>> PredictBatchAsync(List<TInput> inputs);
    Task<TOutput> PredictWithConfidenceAsync(TInput input, out double confidence);
    Task<bool> RetrainModelAsync();
    Task<bool> UpdateModelAsync(byte[] modelData);
}
