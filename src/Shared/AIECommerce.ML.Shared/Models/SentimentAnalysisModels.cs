namespace AIECommerce.ML.Shared.Models;

public class SentimentAnalysisRequest
{
    public string Text { get; set; } = string.Empty;
    public string? Language { get; set; } = "en";
    public bool IncludeKeywords { get; set; } = true;
    public bool IncludeTopics { get; set; } = true;
    public bool IncludeAspectSentiments { get; set; } = true;
    public Dictionary<string, object>? Context { get; set; }
}

public class SentimentAnalysisResult
{
    public string Text { get; set; } = string.Empty;
    public double SentimentScore { get; set; } // -1.0 to 1.0
    public string SentimentLabel { get; set; } = string.Empty; // Positive, Negative, Neutral
    public double Confidence { get; set; }
    public List<string> ExtractedKeywords { get; set; } = new();
    public List<string> DetectedTopics { get; set; } = new();
    public Dictionary<string, double> AspectSentiments { get; set; } = new();
    public List<double> TextEmbedding { get; set; } = new();
    public DateTime AnalyzedAt { get; set; }
}

public class BatchSentimentAnalysisRequest
{
    public List<string> Texts { get; set; } = new();
    public string? Language { get; set; } = "en";
    public bool IncludeKeywords { get; set; } = true;
    public bool IncludeTopics { get; set; } = true;
    public bool IncludeAspectSentiments { get; set; } = true;
}

public class SentimentAnalysisMetrics
{
    public double OverallAccuracy { get; set; }
    public double PositivePrecision { get; set; }
    public double NegativePrecision { get; set; }
    public double NeutralPrecision { get; set; }
    public double AverageConfidence { get; set; }
    public int TotalAnalyzed { get; set; }
    public DateTime CalculatedAt { get; set; }
}
