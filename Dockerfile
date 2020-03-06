FROM microsoft/powershell AS build

RUN apt-get update -y && \
  apt-get install -y git curl --no-install-recommends

FROM build
WORKDIR /root/
CMD pwsh -Command { Invoke-Webrequest -Uri "https://raw.githubusercontent.com/sdaaish/boot/feature/new-boot/boot.ps1"}
