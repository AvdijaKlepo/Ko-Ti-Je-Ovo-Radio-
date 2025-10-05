# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# This stage is used when running from VS in fast mode (Default for Debug configuration)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 5053
EXPOSE 5053


# This stage is used to build the service project
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["KoRadio.API/KoRadio.API.csproj", "KoRadio.API/"]
COPY ["KoRadio.Services/KoRadio.Services.csproj", "KoRadio.Services/"]
COPY ["KoRadio.Model/KoRadio.Model.csproj", "KoRadio.Model/"]
COPY ["Subscriber/Subscriber.csproj", "Subscriber/"]
RUN dotnet restore "./KoRadio.API/KoRadio.API.csproj"
COPY . .
WORKDIR "/src/KoRadio.API"
RUN dotnet build "./KoRadio.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

# This stage is used to publish the service project to be copied to the final stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./KoRadio.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# This stage is used in production or when running from VS in regular mode (Default when not using the Debug configuration)
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "KoRadio.API.dll"]