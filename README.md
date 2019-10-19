# mariadb

[![circleci][circleci]](https://circleci.com/gh/vektorcloud/mariadb)

Tiny Alpine image for running [Mariadb](https://mariadb.com)

## Usage

```bash
docker run --rm -ti -e MYSQL_USER=root -e MYSQL_PASS=root -p 3306:3306 quay.io/vektorcloud/mariadb
```

[circleci]: https://img.shields.io/circleci/build/gh/vektorcloud/mariadb?color=1dd6c9&logo=CircleCI&logoColor=1dd6c9&style=for-the-badge "mariadb"
