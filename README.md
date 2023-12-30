# Dockerize PHP Projects

Using this repository, you can run any version of PHP and Laravel or other frameworks.

To place your source code inside the container, you just need to create a directory named `"app"` in the root path of the project (alongside other directories and files) and place your code inside that directory.

You can use PHP versions from `7.0 to 8.2`. Please avoid from making changes to the docker-compose and Dockerfile files for managing versions and ports and containers name. `To make changes, simply open the .env file and modify the settings there`.

Please be aware that if you change the `name of the php-fpm service`, you should also update the `NGINX_CONTAINER_PHP_UPSTREAM_NAME` variable in the .env file with the same name.

By default, the path that the Nginx web server considers for reading the index.php file in its configuration is as follows:
`/var/www/html/public/`
If you are not using Laravel, you should remove `"public"`.

To do this, simply edit the `.env` file and leave the value of the `NGINX_CONTAINER_PROJECT_PATH` variable `empty`.

Additionally, if you need to change the `domain` in Nginx, you can do so by modifying the `APP_DOMAIN variable`.

``Note:`` If you want to modify the file related to the Nginx virtual host, you should edit the `default.conf.template` file located in the `./nginx/templates/ directory`.

`Please avoid changing the default.conf file in the ./nginx/conf.d/ path`.

To run Docker, use the following command:
`docker-compose up --build -d` OR `docker compose up --build -d`
