#escape=`
ARG OS_VERSION=1809
ARG MONGO_VERSION=4.4.0
ARG MONGO_HOME="C:\mongo"

#### MONGODB INSTALLER

FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS mongo-installer

ARG MONGO_VERSION
ARG MONGO_HOME
ENV MONGO_VERSION=${MONGO_VERSION} `
    MONGO_HOME=${MONGO_HOME}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN $url = ('https://fastdl.mongodb.org/windows/mongodb-windows-x86_64-{0}.zip' -f $env:MONGO_VERSION); `
    Write-Host ('Downloading {0} ...' -f $url); `
    Invoke-WebRequest $url -OutFile 'C:\mongo.zip'; `
    `
    Write-Host 'Unzipping MongoDB ...'; `
    Expand-Archive -Path 'c:\mongo.zip' -DestinationPath C:\; `
    Move-Item "mongodb-win32-x86_64-windows-$env:MONGO_VERSION" $env:MONGO_HOME; `
    `
    Write-Host 'Cleanup MongoDB installation ...'; `
    Remove-Item mongo.zip -Force

#### FINAL IMAGE

FROM mcr.microsoft.com/windows/nanoserver:${OS_VERSION}

ARG MONGO_VERSION
ARG MONGO_HOME
ENV MONGO_VERSION=${MONGO_VERSION} `
    MONGO_HOME=${MONGO_HOME}

COPY --from=mongo-installer ${MONGO_HOME}\bin\mongod.exe C:\mongod.exe

RUN mkdir C:\data\db

EXPOSE 27017

CMD [ "mongod.exe" ]
