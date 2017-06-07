# mariadb

Tiny Alpine image for running [Mariadb](https://mariadb.com)

## Usage

```bash
docker run --rm -ti -e MYSQL_USER=root -e MYSQL_PASS=root -p 3306:3306 quay.io/vektorcloud/mariadb
```