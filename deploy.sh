#!/usr/bin/env bash

docker pull simon987/sist2:latest

ES=http://db.lxd:9200


rm -rf ./*.idx 2> /dev/null

docker run --rm -v $(pwd)/:/host simon987/sist2:latest scan --name "Demo files" -q 1.0 -t 12 --content-size 99999999 /host/demo_files/ -o /host/demo.idx
docker run --rm -v $(pwd)/:/host simon987/sist2:latest scan --name "Linux source code" -q 1 -t 12 --content-size 99999999 /host/linux/ -o /host/linux.idx
docker run --rm -v $(pwd)/:/host simon987/sist2:latest scan --name "Biodiversity Heritage Library" -t 12 -q 1 /host/bhl/ -o /host/bhl.idx

docker run --rm -v $(pwd)/:/host simon987/sist2:latest index --es-url $ES /host/demo.idx

docker run --rm -v $(pwd)/:/host simon987/sist2:latest index --es-url $ES -t 7 --batch-size 40 /host/linux.idx
sleep 30
docker run --rm -v $(pwd)/:/host simon987/sist2:latest exec-script --es-url $ES --script-file /host/script /host/linux.idx

docker run --rm -v $(pwd)/:/host simon987/sist2:latest index --es-url $ES /host/bhl.idx


docker rm -f sist2_demo
docker run --name sist2_demo --restart always -d -v $(pwd)/:/host -p 4090:4090 \
	simon987/sist2:latest web --bind 0.0.0.0:4090 --very-verbose --es-url $ES \
	/host/demo.idx /host/linux.idx /host/bhl.idx
