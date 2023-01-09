#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["demo-app/demo-app.csproj", "demo-app/"]
RUN dotnet restore "demo-app/demo-app.csproj"
COPY . .
WORKDIR "/src/demo-app"
RUN dotnet build "demo-app.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "demo-app.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "demo-app.dll"]