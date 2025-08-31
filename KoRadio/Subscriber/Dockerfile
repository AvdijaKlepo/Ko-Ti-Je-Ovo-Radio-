FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY KoRadio/Subscriber/Subscriber.csproj KoRadio/Subscriber/
RUN dotnet restore KoRadio/Subscriber/Subscriber.csproj

COPY KoRadio/Subscriber/ KoRadio/Subscriber/
WORKDIR /src/KoRadio/Subscriber
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Subscriber.dll"]
