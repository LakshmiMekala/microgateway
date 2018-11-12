#!/bin/bash

# Generate plain HTML Report
function generate::sanity::report() {
    pushd $GOPATH
    FILENAME="examplestestreport.html"
        HTML="<!DOCTYPE html>
        <html><head><style>table {font-family: arial, sans-serif;border-collapse: collapse;margin: auto;}td,th {border: 1px solid #dddddd;text-align: left;padding: 8px;}th {background: #003399;text-align: center;color: #fff;}body {padding-right: 15px;padding-left: 15px;margin-right: auto;margin-left: auto;}label {font-weight: bold;}.test-report h1 {color: #003399;}.summary,.test-report {text-align: center;}.success {background-color: #79d279;}.error {background-color: #ff3300;}.summary-tbl {font-weight: bold;}.summary-tbl td {border: none;}</style></head><body>    <section class=test-report><h1>Examples Sanity Report</h1></section><section class=summary><h2>Summary</h2><table class="summary-tbl"><tr><td>Number of test cases passed </td> <td> </td></tr><tr><td>Number of test cases failed </td> <td> </td></tr><td>Total test cases</td><td> </td></tr></tr></table></section><section class=test-report><h2>Examples Test report</h2><table><tr><th>Type</th><th>Recipe</th><th> Testcase </th><th>Status</th><tr></tr> </table></html>"

    echo $HTML >> $FILENAME
    popd
    x=0 y=0 z=0
    fetch::example::recipeslist
}

# Split recipes list into an array
function get::recipes::list() {
    IFS=\  read -a RECIPE <<<"$samples" ;
    set | grep ^IFS= ;
    # separating arrays by line
    IFS=$' \t\n' ;
    # fetching Gateway
    set | grep ^RECIPE=\\\|^samples= ;
}

# Fatch types(api's and json) list
function fetch::example::recipeslist() {
    pushd $PRIMARYPATH/examples
    TYPES=(*)
    for ((p=0; p<${#TYPES[@]}; p++));
    do
        TYPES[$p]=${TYPES[$p]}
        cd ${TYPES[$p]}
        ls -d * > $GOPATH/${TYPES[$p]}
        cat $GOPATH/${TYPES[$p]}
        cd ..
        samples=$(echo $(cat $GOPATH/${TYPES[$p]}));
        unset RECIPE
        get::recipes::list
        for ((k=0; k<"${#RECIPE[@]}"; k++));
        do
            echo ${RECIPE[$k]}
            microgateway::examples::sanity::test
        done
    done
    popd
}

# run sanity tests
function microgateway::examples::sanity::test() {
    if [[ -f $PRIMARYPATH/examples/${TYPES[$p]}/${RECIPE[$k]}/${RECIPE[$k]}.sh ]]; then
        pushd $PRIMARYPATH/examples/${TYPES[$p]}/${RECIPE[$k]};
        source ./${RECIPE[$k]}.sh
        value=($(get_test_cases))
        sleep 10        
        for ((i=0;i < ${#value[@]};i++))
        do
            value1=$(${value[i]})
            sleep 10
            if [[ $value1 == *"PASS"* ]];  then
                echo "${value[i]}-${RECIPE[$k]}":"Passed"
                x=$((x+1))
                sed -i "s/<\/tr> <\/table>/<tr><td>${TYPES[$p]}<\/td><td>${RECIPE[$k]}<\/td><td>${value[i]}<\/td><td  class="success">PASS<\/td><\/tr><\/tr> <\/table>/g" $GOPATH/$FILENAME
            else
                echo "${value[i]}-${RECIPE[$k]}":"Failed"
                y=$((y+1))     
                sed -i "s/<\/tr> <\/table>/<tr><td>${TYPES[$p]}<\/td><td>${RECIPE[$k]}<\/td><td>${value[i]}<\/td><td  class="error">FAIL<\/td><\/tr><\/tr> <\/table>/g" $GOPATH/$FILENAME
            fi
            z=$((z+1))
        done
        popd
    else
        echo "Sanity file does not exist"
        sed -i "s/<\/tr> <\/table>/<tr><td>${TYPES[$p]}<\/td><td>${RECIPE[$k]}<\/td><td>NA<\/td><td>NA<\/td><\/tr><\/tr> <\/table>/g" $GOPATH/$FILENAME
    fi    
}