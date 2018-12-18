
docker pull mariadb
docker run --name my-mariadb -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=ss4 -p 3306:3306 -d mariadb:latest
##get IPAddress
docker inspect my-mariadb


cd base-image
docker build -t="alpine_ap:latest" .

docker build -t="ss4:latest" .
##docker build --build-arg SKIPTESTS=true -t="ss4:latest" .

docker run -d -p 80:8080 --name ss4_mariadb --link my-mariadb:mysql ss4
