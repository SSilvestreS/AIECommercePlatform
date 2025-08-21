using System.ComponentModel.DataAnnotations;

namespace AIECommerce.Shared.Entities;

public class Review : BaseEntity
{
    [Required]
    public Guid ProductId { get; set; }
    
    [Required]
    public Guid UserId { get; set; }
    
    [Required]
    [Range(1, 5)]
    public int Rating { get; set; }
    
    [Required]
    [MaxLength(1000)]
    public string Comment { get; set; } = string.Empty;
    
    public string? Title { get; set; }
    
    public List<string> Images { get; set; } = new();
    
    public bool IsVerifiedPurchase { get; set; }
    
    public bool IsHelpful { get; set; }
    
    public int HelpfulCount { get; set; }
    
    // ML Sentiment Analysis
    public double? SentimentScore { get; set; }
    
    public string? SentimentLabel { get; set; } // Positive, Negative, Neutral
    
    public double? Confidence { get; set; }
    
    public List<string>? ExtractedKeywords { get; set; }
    
    public List<string>? DetectedTopics { get; set; }
    
    public Dictionary<string, double>? AspectSentiments { get; set; }
    
    // Vector embeddings for ML
    public List<double>? CommentEmbedding { get; set; }
    
    public List<double>? TitleEmbedding { get; set; }
    
    // Relationships
    public Product Product { get; set; } = null!;
    
    public User User { get; set; } = null!;
}
