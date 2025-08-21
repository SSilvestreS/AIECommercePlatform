namespace AIECommerce.ML.Shared.Models;

public class FraudDetectionRequest
{
    public Guid UserId { get; set; }
    public Guid? OrderId { get; set; }
    public decimal OrderAmount { get; set; }
    public string PaymentMethod { get; set; } = string.Empty;
    public string IPAddress { get; set; } = string.Empty;
    public string DeviceType { get; set; } = string.Empty;
    public string UserAgent { get; set; } = string.Empty;
    public string ShippingCountry { get; set; } = string.Empty;
    public string BillingCountry { get; set; } = string.Empty;
    public bool IsFirstTimeCustomer { get; set; }
    public TimeSpan? TimeFromLastOrder { get; set; }
    public int ItemsInCart { get; set; }
    public decimal AverageItemPrice { get; set; }
    public List<string> ProductCategories { get; set; } = new();
    public Dictionary<string, object>? AdditionalFeatures { get; set; }
}

public class FraudDetectionResult
{
    public Guid RequestId { get; set; }
    public double FraudRiskScore { get; set; } // 0.0 to 1.0
    public string FraudRiskLevel { get; set; } = string.Empty; // Low, Medium, High
    public bool IsFraudulent { get; set; }
    public double Confidence { get; set; }
    public List<string> RiskFactors { get; set; } = new();
    public Dictionary<string, double> FeatureImportance { get; set; } = new();
    public string Recommendation { get; set; } = string.Empty;
    public DateTime AnalyzedAt { get; set; }
}

public class BatchFraudDetectionRequest
{
    public List<FraudDetectionRequest> Requests { get; set; } = new();
    public bool PrioritizeHighRisk { get; set; } = true;
    public int MaxBatchSize { get; set; } = 100;
}

public class FraudDetectionMetrics
{
    public double TruePositiveRate { get; set; }
    public double TrueNegativeRate { get; set; }
    public double FalsePositiveRate { get; set; }
    public double FalseNegativeRate { get; set; }
    public double Precision { get; set; }
    public double Recall { get; set; }
    public double F1Score { get; set; }
    public double AUC { get; set; }
    public int TotalAnalyzed { get; set; }
    public int FraudulentDetected { get; set; }
    public DateTime CalculatedAt { get; set; }
}
