#!/bin/bash

echoerr()
{
    echo "$@" >&2
}

TEST1="1. Test mysort (C++) with 8 threads and 16GB of data                          "
TEST1_ARGS="1 cpp 160000 data.in data.out 8"
TEST2="2. Test mysort (C++) with 8 threads and 64GB of data                          "
TEST2_ARGS="2 cpp 640000 data.in data.out 8"
TEST3="3. Test mysort (Java) with 8 threads and 16GB of data                         "
TEST3_ARGS="3 java 160000 data.in data.out 8"
TEST4="4. Test mysort (Java) with 8 threads and 64GB of data                         "
TEST4_ARGS="4 java 640000 data.in data.out 8"

NUM_TESTS=4

STATUS=0

TEST()
{
    local testnum=$1
    local implementation=$2
    local numRecords=$3
    local inputFile=$4
    local outputFile=$5
    local numThreads=$6
    local program=""
    local cmd=""

    if [ "$implementation" == "cpp" ]
    then
        program="mysort"
        cmd="./mysort $inputFile $outputFile $numThreads"
    fi

    if [ "$implementation" == "java" ]
    then
        program="mysort.jar"
        cmd="java -cp mysort.jar MySort $inputFile $outputFile $numThreads"
    fi

    if [ ! -f $program ]
    then
        local var="TEST$testnum"
        local msg1="${!var} failed!"
        local msg2= "*** $program is missing ***"
        echo -e "$msg1\n$msg2"
    else
        ./cs553-fall2022-hw5-testing/gensort -a -b0 -t8 $numRecords data.in
        eval $cmd &> mysort.log
        ./cs553-fall2022-hw5-testing/valsort -t8 -o data.sum data.out &> valsort.log
        
        local rc=$(cat valsort.log | grep "SUCCESS" | wc -l)
        if [ $rc -eq 1 ]
        then
            local var="TEST$testnum"
            local msg1="${!var} passed!"
            local msg2="*** Test $testnum run log ***"
            local msg3=">>> ./gensort -a -b0 -t8 $numRecords data.in"
            local msg4=">>> $cmd"
            local msg5=$(cat mysort.log)
            local msg6=">>> ./valsort -t8 -o data.sum data.out"
            local msg7=$(cat valsort.log)
            local msg8="*** Sort successful ***"
            echo -e "$msg1\n$msg2\n$msg3\n$msg4\n$msg5\n$msg6\n$msg7\n$msg8"

            if [ "$implementation" == "cpp" ]
            then
                STATUS=$(($STATUS + 1))
            fi

            if [ "$implementation" == "java" ]
            then
                STATUS=$(($STATUS + 10))
            fi
        else
            local var="TEST$testnum"
            local msg1="${!var} failed!"
            local msg2="*** Test $testnum run log ***"
            local msg3=">>> ./gensort -a -b0 -t8 $numRecords data.in"
            local msg4=">>> $cmd"
            local msg5=$(cat mysort.log)
            local msg6=">>> ./valsort -t8 -o data.sum data.out"
            local msg7=$(cat valsort.log)
            local msg8="*** Sort failed ***"
            echo -e "$msg1\n$msg2\n$msg3\n$msg4\n$msg5\n$msg6\n$msg7\n$msg8"
        fi
    fi
}

HOW_TO_USE="HOW TO USE: bash cs553-fall2022-hw5-testing/test-submission.sh [<check number> | list | all]"

if [ $# -ne 1 ]
then
    echoerr "$HOW_TO_USE"
    exit 1
fi

arg1=$1

if [ "$arg1" == "list" ]
then
    echo "List of available checks:"
    for((i=1;i<=$NUM_TESTS;i++))
    do
        var="TEST$i"
        echo "${!var}"
    done
    exit 0
fi

if [ "$arg1" == "all" ]
then
    for((i=1;i<=$NUM_TESTS;i++))
    do
        var="TEST${i}_ARGS"
        cmd="TEST ${!var}"
        eval $cmd
    done
    
    if [ ${STATUS:0:1} -eq 2 ] || [ ${STATUS:1:2} -eq 2 ]
    then
        exit 0
    fi
    
    exit 1
fi

if [ $arg1 -eq $arg1 ]
then
    var="TEST${i}_ARGS"
    cmd="TEST ${!var}"
    eval $cmd
    
    if [ ${STATUS:0:1} -eq 1 ] || [ ${STATUS:1:2} -eq 1 ]
    then
        exit 0
    fi
    
    exit 1
else
    echoerr "$HOW_TO_USE"
    exit 2
fi

exit 0