namespace AIECommerce.ML.Shared.Models;

public class DemandForecastingRequest
{
    public Guid ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public List<HistoricalDataPoint> HistoricalData { get; set; } = new();
    public int ForecastHorizon { get; set; } = 30; // days
    public string Seasonality { get; set; } = "weekly"; // daily, weekly, monthly, yearly
    public bool IncludeConfidenceIntervals { get; set; } = true;
    public Dictionary<string, object>? ExternalFactors { get; set; }
}

public class HistoricalDataPoint
{
    public DateTime Date { get; set; }
    public int Quantity { get; set; }
    public decimal Price { get; set; }
    public int StockLevel { get; set; }
    public bool IsPromotion { get; set; }
    public string? Season { get; set; }
    public bool IsHoliday { get; set; }
    public Dictionary<string, object>? AdditionalFeatures { get; set; }
}

public class DemandForecast
{
    public Guid ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public List<ForecastDataPoint> ForecastData { get; set; } = new();
    public double ModelAccuracy { get; set; }
    public string ModelType { get; set; } = string.Empty; // LSTM, ARIMA, Prophet, etc.
    public DateTime ForecastGeneratedAt { get; set; }
    public DateTime ValidUntil { get; set; }
}

public class ForecastDataPoint
{
    public DateTime Date { get; set; }
    public int PredictedQuantity { get; set; }
    public int? LowerBound { get; set; }
    public int? UpperBound { get; set; }
    public double Confidence { get; set; }
    public Dictionary<string, double> FeatureContributions { get; set; } = new();
}

public class DemandForecastingMetrics
{
    public double MAE { get; set; } // Mean Absolute Error
    public double RMSE { get; set; } // Root Mean Square Error
    public double MAPE { get; set; } // Mean Absolute Percentage Error
    public double R2Score { get; set; }
    public double ForecastAccuracy { get; set; }
    public int TotalForecasts { get; set; }
    public DateTime CalculatedAt { get; set; }
}
