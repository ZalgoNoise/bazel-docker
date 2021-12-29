#!/bin/zsh
#
#TODO: redo this with Bazel

docker-compose build --parallel

list=`cat docker-compose.yaml \
| grep image \
| awk '{print $NF}' \
| sed 's/${BAZELL}/4.2.2/g' \
| sed 's/${BAZEL5}/5.0.0-pre.20211011.2/g' \
| sed 's/${BAZEL6}/6.0.0-pre.20211215.3/g'` 

versions=()
echo $list \
| while NF=$'\n' read -r line
    do versions+=($line); 
    done

prefixes=(
    "zalgonoise/" 
    "ghcr.io/zalgonoise/"
)
repos=(
    "https://index.docker.io/v1/" 
    "ghcr.io"
)

for (( r=1 ; r<=${#repos[@]} ; r++))
do 
    echo -e "---\nDocker login: ${repos[r]}\n---"
    docker login ${repos[r]}

    for (( i=1 ; i<=${#versions[@]} ; i++))
    do
        echo -e "# Tagging ${versions[i]} as ${prefixes[r]}${versions[i]}"
        docker tag ${versions[i]} ${prefixes[r]}${versions[i]}

        echo -e "# Pushing ${prefixes[r]}${versions[i]}"
        docker push ${prefixes[r]}${versions[i]}
    done
done
