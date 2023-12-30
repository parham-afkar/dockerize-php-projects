# Dockerize PHP Projects

Using this repository, you can run any version of PHP and Laravel or other frameworks.

To place your source code inside the container, you just need to create a directory named `"app"` in the root path of the project (alongside other directories and files) and place your code inside that directory.

You can use PHP versions from `7.0 to 8.2`. Please avoid from making changes to the docker-compose and Dockerfile files for managing versions and ports and containers name. `To make changes, simply open the .env file and modify the settings there`.

Please be aware that if you change the `name of the php-fpm service`, you should also update the `NGINX_CONTAINER_PHP_UPSTREAM_NAME` variable in the .env file with the same name.

To run Docker, use the following command:
`docker-compose up --build -d` OR `docker compose up --build -d`
