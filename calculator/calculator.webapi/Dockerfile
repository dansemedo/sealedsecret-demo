FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-stretch-slim AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/core/sdk:2.2-stretch AS build
WORKDIR /src
COPY ["calculator.webapi/calculator.webapi.csproj", "calculator.webapi/"]
RUN dotnet restore "calculator.webapi/calculator.webapi.csproj"
COPY . .
WORKDIR "/src/calculator.webapi"
RUN dotnet build "calculator.webapi.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "calculator.webapi.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "calculator.webapi.dll"]