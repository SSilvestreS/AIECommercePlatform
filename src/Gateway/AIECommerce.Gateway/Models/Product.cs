namespace AIECommerce.Gateway.Models;

/// <summary>
/// Modelo que representa um produto na plataforma AIECommerce
/// Contém todas as informações essenciais para exibição e processamento
/// </summary>
public class Product
{
    /// <summary>
    /// Identificador único do produto
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Nome do produto para exibição
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Descrição detalhada do produto
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// Preço atual do produto em reais (R$)
    /// </summary>
    public decimal Price { get; set; }

    /// <summary>
    /// Categoria principal do produto
    /// </summary>
    public string Category { get; set; } = string.Empty;

    /// <summary>
    /// Quantidade disponível em estoque
    /// </summary>
    public int StockQuantity { get; set; }

    /// <summary>
    /// Avaliação média do produto (0.0 a 5.0)
    /// </summary>
    public decimal Rating { get; set; }

    /// <summary>
    /// URL da imagem principal do produto
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
    /// Indica se o produto está ativo e disponível para venda
    /// </summary>
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// Tags associadas ao produto para melhorar busca e categorização
    /// </summary>
    public List<string> Tags { get; set; } = new();

    /// <summary>
    /// Características técnicas do produto (especificações)
    /// </summary>
    public Dictionary<string, string> Specifications { get; set; } = new();

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
}
