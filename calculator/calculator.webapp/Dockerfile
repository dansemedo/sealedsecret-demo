FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-stretch-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:2.2-stretch AS build
WORKDIR /src
COPY ["calculator.webapp/calculator.webapp.csproj", "calculator.webapp/"]
RUN dotnet restore "calculator.webapp/calculator.webapp.csproj"
COPY . .
WORKDIR "/src/calculator.webapp"
RUN dotnet build "calculator.webapp.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "calculator.webapp.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "calculator.webapp.dll"]