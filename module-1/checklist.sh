#!/bin/bash +x

CLUSTER=$1
ZONE=$2
CHECKS=$3

passfail () {
	operator=$1
	expected=$2
	selector=$3
	msg=$4

	v=$(gcloud container clusters describe $CLUSTER --format="value($selector)" --zone $ZONE)

	case $operator in
	M)
		if [ "X$v" == "X$expected" ]; then
			printf "\e[32m [PASS] \e[0m %s: %s\n" "$msg" $v
		else
			printf "\e[31m [FAIL] \e[0m %s: %s (should be: %s)\n" "$msg" $v $expected
		fi
		;;
	N)
		if [ "X$v" != "X$expected" ]; then
			printf "\e[32m [PASS] \e[0m %s: %s\n" "$msg" $v
		else
			printf "\e[31m [FAIL] \e[0m %s should not be: %s)\n" "$msg" $expected
		fi
		;;
	E)
		if [ -z "$v" ]; then
			printf "\e[32m [PASS] \e[0m %s\n" "$msg" 
		else
			printf "\e[31m [FAIL] \e[0m %s should have no value\n" $selector
		fi
		;;
	*)
		printf "\e[31m [ERROR] \e[0m unknown operator %s\n" $operator
		;;
	esac
}

while IFS="," read op exp sel m 
do
    passfail $op $exp $sel "$m"
done < ${CHECKS:-/dev/stdin}

exit 0

