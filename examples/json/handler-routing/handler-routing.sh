#!/bin/bash

function get_test_cases {
    init ;  
    local my_list=( testcase1 testcase2 testcase3 )     
    echo "${my_list[@]}"
    # clear ;
}

function init {
    flogo create -f flogo.json > /tmp/test 2>&1
    cd MyProxy
    flogo build > /tmp/test 2>&1
    cd ..
}

function clear {
    rm -rf MyProxy
}

function testcase1 {
./MyProxy/bin/MyProxy  > /tmp/handler1.log 2>&1 &
pId=$!
sleep 5
response=$(curl --request GET http://localhost:9096/pets/1 --write-out '%{http_code}' --silent --output /dev/null) 
curl http://localhost:9096/pets/1 > /tmp/test.log 2>&1
if [ $response -eq 200 ] && [[ "echo $(cat /tmp/handler1.log)" =~ "Code identified in response output: 200" ]]
    then 
        echo "PASS"
    else
        echo "FAIL"
fi
kill -9 $pId
rm -rf /tmp/handler1.log
}

function testcase2 {
./MyProxy/bin/MyProxy  > /tmp/handler2.log 2>&1 &
pId=$!
sleep 5
response=$(curl --request GET http://localhost:9096/pets/8 --write-out '%{http_code}' --silent --output /dev/null) 
curl http://localhost:9096/pets/8 > /tmp/test2.log 2>&1
if [ $response -eq 404 ] && [[ "echo $(cat /tmp/handler2.log)" =~ "Code identified in response output: 404" ]] && [[ "echo $(cat /tmp/test2.log)" =~ "id must be less than 8" ]]
    then 
        echo "PASS"
    else
        echo "FAIL"
fi
kill -9 $pId
rm -rf /tmp/handler2.log     
}


function testcase3 {
./MyProxy/bin/MyProxy  > /tmp/handler3.log 2>&1 &
pId=$!
sleep 5
response=$(curl -H "Auth: 1337" http://localhost:9096/pets/8 --write-out '%{http_code}' --silent --output /dev/null)
if [ $response -eq 200 ] && [[ "echo $(cat /tmp/handler3.log)" =~ "Code identified in response output: 200" ]]
    then 
        echo "PASS"
    else
        echo "FAIL"
fi
sleep 5
kill -9 $pId
rm -rf /tmp/handler3.log
}

