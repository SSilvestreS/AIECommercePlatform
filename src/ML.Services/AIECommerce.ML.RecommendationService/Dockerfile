FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5001

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["AIECommerce.ML.RecommendationService.csproj", "./"]
RUN dotnet restore "AIECommerce.ML.RecommendationService.csproj"
COPY . .
WORKDIR "/src"
RUN dotnet build "AIECommerce.ML.RecommendationService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "AIECommerce.ML.RecommendationService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "AIECommerce.ML.RecommendationService.dll"]
