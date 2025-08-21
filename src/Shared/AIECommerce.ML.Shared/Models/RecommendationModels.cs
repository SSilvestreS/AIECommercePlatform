namespace AIECommerce.ML.Shared.Models;

public class ProductRecommendationRequest
{
    public Guid UserId { get; set; }
    public Guid? ProductId { get; set; }
    public List<Guid>? ProductIds { get; set; }
    public string? Category { get; set; }
    public int MaxRecommendations { get; set; } = 10;
    public bool IncludeSimilarProducts { get; set; } = true;
    public bool IncludePersonalizedRecommendations { get; set; } = true;
    public Dictionary<string, object>? Context { get; set; }
}

public class ProductRecommendation
{
    public Guid ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public double Score { get; set; }
    public string RecommendationType { get; set; } = string.Empty; // Collaborative, Content-based, Popularity
    public string Reason { get; set; } = string.Empty;
    public Dictionary<string, double>? FeatureContributions { get; set; }
    public double Confidence { get; set; }
}

public class UserRecommendationRequest
{
    public Guid UserId { get; set; }
    public List<Guid>? ExcludeProductIds { get; set; }
    public string? PreferredCategory { get; set; }
    public decimal? MaxPrice { get; set; }
    public int MaxRecommendations { get; set; } = 20;
    public bool IncludeDiversity { get; set; } = true;
    public Dictionary<string, object>? UserPreferences { get; set; }
}

public class RecommendationMetrics
{
    public double Precision { get; set; }
    public double Recall { get; set; }
    public double F1Score { get; set; }
    public double NDCG { get; set; }
    public double ClickThroughRate { get; set; }
    public double ConversionRate { get; set; }
    public double AverageRating { get; set; }
    public DateTime CalculatedAt { get; set; }
}
