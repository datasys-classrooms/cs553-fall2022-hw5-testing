#!/bin/bash

echoerr()
{
    echo "$@" >&2
}

STATUS=0

CHECK1()
{
    MSG="1. Check to see if the README is updated ...                                    "
    if [ ! -f README.md ]
    then
        echo "$MSG failed!"
        STATUS=2
    else
        local rc=$(cat README.md | grep "please-write" | wc -l)
        if [ $rc -eq 0 ]
        then
            echo "$MSG passed!"
        else
            echo "$MSG failed!"
            STATUS=1
        fi
    fi
}

CHECK2()
{
    MSG="2. Check to see if the report is uploaded ...                                   "
    if [ ! -f hw5-report.pdf ]
    then
        echo "$MSG failed!"
        STATUS=2
    else
        local rc=$(ls -l hw5-report.pdf | tr -s ' ' | cut -d ' ' -f5)
        if [ $rc -ne 3653 ]
        then
            echo "$MSG passed!" 
        else
            echo "$MSG failed!"
            STATUS=1
        fi
    fi
}

CHECK3()
{
    MSG="3. Check to see if the code is uploaded ...                                     "
    if [ ! -f mysort.c ]
    then
        echo "$MSG failed!"
        STATUS=2
    else
        local rc=$(ls -l mysort.c | tr -s ' ' | cut -d ' ' -f5)
        if [ $rc -ne 1872 ]
        then
            echo "$MSG passed!" 
        else
            echo "$MSG failed!"
            STATUS=1
        fi
    fi
}

CHECK4()
{
    MSG="4. Check to see if the mysort script is not modified ...                        "
    if [ ! -f run-mysort.sh ]
    then
        echo "$MSG failed!"
        STATUS=2
    else
        local rc=$(ls -l run-mysort.sh | tr -s ' ' | cut -d ' ' -f5)
        if [ $rc -eq 339 ]
        then
            echo "$MSG passed!" 
        else
            echo "$MSG failed!"
            STATUS=1
        fi
    fi
}

CHECK5()
{
    MSG="5. Check to see if the code compiles ...                                        "
    if [ ! -f Makefile ]
    then
        echo "$MSG failed!"
        echo "*** Makefile is missing ***"
        STATUS=2
    else
        echo -n "" > mysort.log
        make clean &>> mysort.log
        make &>> mysort.log
        local rc=$(cat mysort.log | grep -E "error:" | wc -l)
        if [ $rc -eq 0 ]
        then
            echo "$MSG passed!" 
        else
            echo "$MSG failed!"
            echo "*** Check 5 run log ***"
            cat cpubench.log
            echo "*** End of log ***"
            STATUS=1
        fi
    fi
}

NUM_CHECKS=5
HOW_TO_USE="HOW TO USE: bash cs553-fall2022-hw5-testing/check-submission.sh [<check number> | list | all]"

if [ $# -ne 1 ]
then
    echoerr "$HOW_TO_USE"
    exit 1
fi

arg1=$1

if [ "$arg1" == "list" ]
then
    echo "List of available checks:"
    echo "1. Check to see if the README is updated"
    echo "2. Check to see if the report is uploaded"
    echo "3. Check to see if the code is uploaded"
    echo "4. Check to see if the mysort script is not modified"
    echo "5. Check to see if the code compiles"
    exit 0
fi

if [ "$arg1" == "all" ]
then
    for((i=1;i<=$NUM_CHECKS;i++))
    do
        CHECK$i
    done
    if [ $STATUS -ne 0 ]
    then
        exit 1
    fi
    exit 0
fi

if [ $arg1 -eq $arg1 ]
then
    CHECK$arg1
    if [ $STATUS -ne 0 ]
    then
        exit 1
    fi
else
    echoerr "$HOW_TO_USE"
    exit 2
fi

exit 0