# Dockerize PHP Projects

You can run any version of Laravel

Step 1: Download Laravel or any other project source codes in to `app` directory.

Step 2: If you are not using SSL remove `HTTPS Section` in `./nginx/templates/default.conf.template`.

## Please don't edit `./nginx/conf.d/` files, apply your changes to `./nginx/templates/default.conf.template`

Step 3: If you want to change the `version` of all services or `ports` or `path (root project)` and etc..., edit `./.env` file.

Step 4: Run `docker compose up --build -d` OR `docker-compose up --build -d`.
