using System.ComponentModel.DataAnnotations;

namespace AIECommerce.Shared.Entities;

public class Product : BaseEntity
{
    [Required]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(1000)]
    public string Description { get; set; } = string.Empty;
    
    [Required]
    public decimal Price { get; set; }
    
    public decimal? OriginalPrice { get; set; }
    
    [Required]
    public int StockQuantity { get; set; }
    
    [MaxLength(100)]
    public string SKU { get; set; } = string.Empty;
    
    [MaxLength(50)]
    public string Brand { get; set; } = string.Empty;
    
    [MaxLength(100)]
    public string Category { get; set; } = string.Empty;
    
    public List<string> Tags { get; set; } = new();
    
    public List<string> Images { get; set; } = new();
    
    public Dictionary<string, object> Attributes { get; set; } = new();
    
    // ML Features
    public double? AverageRating { get; set; }
    
    public int TotalReviews { get; set; }
    
    public int TotalSales { get; set; }
    
    public double? PopularityScore { get; set; }
    
    public List<double> PriceHistory { get; set; } = new();
    
    public List<int> SalesHistory { get; set; } = new();
    
    public DateTime? LastPriceChange { get; set; }
    
    public DateTime? LastStockUpdate { get; set; }
    
    // Vector embeddings for ML
    public List<double>? NameEmbedding { get; set; }
    
    public List<double>? DescriptionEmbedding { get; set; }
    
    public List<double>? CategoryEmbedding { get; set; }
    
    // Relationships
    public List<Review> Reviews { get; set; } = new();
    
    public List<OrderItem> OrderItems { get; set; } = new();
    
    public List<ProductRecommendation> Recommendations { get; set; } = new();
}
