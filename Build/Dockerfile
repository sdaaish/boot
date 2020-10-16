FROM mcr.microsoft.com/powershell:ubuntu-18.04 AS build

RUN apt-get update -y && \
  apt-get install -y git curl stow --no-install-recommends

FROM build
COPY . /src/
WORKDIR /src
RUN pwsh -File boot.ps1
