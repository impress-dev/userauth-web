#!/bin/bash

if [ -z "$1" ]
  then
    echo "Usage: ./install.sh <Wappler-project-directory>"
    exit 1
fi

if [ ! -d "$1" ]
then
    echo "The supplied Wappler project does not exist"
    exit 1
fi

if [ ! -d "$1/.git" ]
then
    echo "The supplied Wappler project needs to be a valid git project"
    exit 1
fi

if [ ! -d "$1/views" ]
then
    echo "The supplied parameter is not a valid Wappler project (missing views folder)"
    exit 1
fi

if [ ! -d "$1/views/layouts" ]
then
    echo "The supplied parameter is not a valid Wappler project (missing views/layous folder)"
    exit 1
fi

if [ ! -d "$1/app/api" ]
then
    echo "The supplied parameter is not a valid Wappler project (missing app/api folder)"
    exit 1
fi

if [ ! -f "$1/app/config/routes.json" ]
then
    echo "The supplied parameter is not a valid Wappler project (missing app/config/routes.json)"
    exit 1
fi

echo "Wappler project directory: $1"

if [ -d "$1/views/userauth-web" ]
then
    echo "INFO: views/userauth-web already exists so not re-adding as sub-module"
else
    echo "INFO: Adding userauth-web"
    git submodule add https://github.com/impress-dev/userauth-web.git "$1/views/userauth-web"
fi

if [ -d "$1/views/layouts/userauth-web" ]
then
    echo "INFO: views/layouts/userauth-web already exists so not re-adding as sub-module"
else
    echo "INFO: Adding userauth-layouts"
    git submodule add https://github.com/impress-dev/userauth-layouts.git "$1/views/layouts/userauth-web"
fi

if [ -d "$1/public/css/userauth-web" ]
then
    echo "INFO: public/css/userauth-web already exists so not re-adding as sub-module"
else
    echo "INFO: Adding userauth-css"
    git submodule add https://github.com/impress-dev/userauth-css.git "$1/public/css/userauth-web"
fi

if [ -d "$1/app/api/userauth-api" ]
then
    echo "INFO: app/api/userauth-api already exists so not re-adding as sub-module"
else
    echo "INFO: Adding userauth-api"
    git submodule add https://github.com/impress-dev/userauth-api.git "$1/app/api/userauth-api"
fi

if grep -Fq "userauth-web" "$1/app/config/routes.json"
then
    echo "INFO: userauth-web already exists in routes.json so not re-adding routes"
else
    head -n 2 "$1/app/config/routes.json" > "$1/app/config/routes.json.new"
    curl -s https://raw.githubusercontent.com/impress-dev/userauth-web/main/userauth-routes.json.snippet >> "$1/app/config/routes.json.new"
    tail -n +3 "$1/app/config/routes.json" >> "$1/app/config/routes.json.new"
    ROUTES_BACKUP="$1/app/config/routes.json.$(date +"%Y%m%d-%H%M%S")"
    mv "$1/app/config/routes.json" "$ROUTES_BACKUP"
    echo "INFO: routes.json has been backed up to: $ROUTES_BACKUP"
    mv "$1/app/config/routes.json.new" "$1/app/config/routes.json"
fi

if [ ! -d "$1/app/modules" ]
then
    mkdir "$1/app/modules"
fi

if [ ! -f "$1/app/modules/global.json" ]
then
    echo "INFO: Adding global.json"
    curl -s https://raw.githubusercontent.com/impress-dev/userauth-web/main/userauth-global.json --output "$1/app/modules/global.json"
elif grep -Fq "STEWARD_PASSWORD" "$1/app/modules/global.json"
then
    echo "INFO: global.json already contains STEWARD_PASSWORD so not re-adding ENV variables"
else
    echo "WARNING: global.json already exists and so required ENV variables will need to be added manually"
fi
