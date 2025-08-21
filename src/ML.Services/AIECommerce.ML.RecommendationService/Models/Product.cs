namespace AIECommerce.ML.RecommendationService.Models;

/// <summary>
/// Modelo de produto utilizado pelo serviço de recomendações ML
/// Contém todas as informações necessárias para algoritmos de Machine Learning
/// </summary>
public class Product
{
    /// <summary>
    /// Identificador único do produto no sistema
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Nome do produto para exibição e busca
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Descrição detalhada do produto para análise de conteúdo
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// Preço atual do produto em reais (R$)
    /// </summary>
    public decimal Price { get; set; }

    /// <summary>
    /// Categoria principal do produto para segmentação
    /// </summary>
    public string Category { get; set; } = string.Empty;

    /// <summary>
    /// Quantidade disponível em estoque
    /// </summary>
    public int StockQuantity { get; set; }

    /// <summary>
    /// Avaliação média do produto (0.0 a 5.0) para algoritmos colaborativos
    /// </summary>
    public decimal Rating { get; set; }

    /// <summary>
    /// URL da imagem principal do produto para análise visual
    /// </summary>
    public string ImageUrl { get; set; } = string.Empty;

    /// <summary>
    /// Data de criação do registro do produto
    /// </summary>
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// Data da última atualização do produto
    /// </summary>
    public DateTime UpdatedAt { get; set; }

    /// <summary>
    /// Indica se o produto está ativo e disponível para recomendações
    /// </summary>
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// Tags associadas ao produto para melhorar categorização ML
    /// </summary>
    public List<string> Tags { get; set; } = new();

    /// <summary>
    /// Características técnicas do produto para algoritmos baseados em conteúdo
    /// </summary>
    public Dictionary<string, string> Specifications { get; set; } = new();

    /// <summary>
    /// Score de relevância calculado pelos algoritmos ML
    /// </summary>
    public decimal RelevanceScore { get; set; }

    /// <summary>
    /// Indica se o produto foi visualizado pelo usuário
    /// </summary>
    public bool IsViewed { get; set; }

    /// <summary>
    /// Indica se o produto foi adicionado ao carrinho
    /// </summary>
    public bool IsAddedToCart { get; set; }

    /// <summary>
    /// Indica se o produto foi comprado pelo usuário
    /// </summary>
    public bool IsPurchased { get; set; }

    /// <summary>
    /// Número de visualizações do produto
    /// </summary>
    public int ViewCount { get; set; }

    /// <summary>
    /// Número de vezes que o produto foi adicionado ao carrinho
    /// </summary>
    public int CartAddCount { get; set; }

    /// <summary>
    /// Número de vendas do produto
    /// </summary>
    public int SalesCount { get; set; }

    /// <summary>
    /// Calcula o preço com desconto baseado em uma porcentagem
    /// </summary>
    /// <param name="discountPercentage">Porcentagem de desconto (0-100)</param>
    /// <returns>Preço com desconto aplicado</returns>
    public decimal GetDiscountedPrice(decimal discountPercentage)
    {
        if (discountPercentage < 0 || discountPercentage > 100)
            throw new ArgumentException("Porcentagem de desconto deve estar entre 0 e 100");

        var discount = Price * (discountPercentage / 100m);
        return Price - discount;
    }

    /// <summary>
    /// Verifica se o produto está em estoque
    /// </summary>
    /// <returns>True se há estoque disponível</returns>
    public bool IsInStock()
    {
        return StockQuantity > 0;
    }

    /// <summary>
    /// Verifica se o produto está com estoque baixo (menos de 10 unidades)
    /// </summary>
    /// <returns>True se o estoque está baixo</returns>
    public bool IsLowStock()
    {
        return StockQuantity > 0 && StockQuantity < 10;
    }

    /// <summary>
    /// Obtém a classificação textual baseada na avaliação numérica
    /// </summary>
    /// <returns>Classificação em texto (ex: "Excelente", "Bom", etc.)</returns>
    public string GetRatingText()
    {
        return Rating switch
        {
            >= 4.5m => "Excelente",
            >= 4.0m => "Muito Bom",
            >= 3.5m => "Bom",
            >= 3.0m => "Regular",
            >= 2.0m => "Ruim",
            _ => "Muito Ruim"
        };
    }

    /// <summary>
    /// Calcula o score de popularidade baseado em métricas de engajamento
    /// </summary>
    /// <returns>Score de popularidade (0.0 a 1.0)</returns>
    public decimal CalculatePopularityScore()
    {
        var viewWeight = 0.3m;
        var cartWeight = 0.4m;
        var purchaseWeight = 0.3m;

        var maxViews = 1000; // Normalização
        var maxCartAdds = 100;
        var maxSales = 50;

        var normalizedViews = Math.Min(1.0m, ViewCount / (decimal)maxViews);
        var normalizedCartAdds = Math.Min(1.0m, CartAddCount / (decimal)maxCartAdds);
        var normalizedSales = Math.Min(1.0m, SalesCount / (decimal)maxSales);

        return (normalizedViews * viewWeight) + 
               (normalizedCartAdds * cartWeight) + 
               (normalizedSales * purchaseWeight);
    }

    /// <summary>
    /// Verifica se o produto é considerado popular
    /// </summary>
    /// <returns>True se o produto é popular</returns>
    public bool IsPopular()
    {
        return CalculatePopularityScore() > 0.7m;
    }

    /// <summary>
    /// Obtém o status de estoque em formato legível
    /// </summary>
    /// <returns>Status do estoque (ex: "Em estoque", "Estoque baixo", "Sem estoque")</returns>
    public string GetStockStatus()
    {
        if (StockQuantity == 0)
            return "Sem estoque";
        
        if (StockQuantity < 10)
            return "Estoque baixo";
        
        if (StockQuantity < 50)
            return "Estoque moderado";
        
        return "Em estoque";
    }
}
