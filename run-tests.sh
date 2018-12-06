#!/bin/bash
which goss

if [ $? -ne 0 ]; then
	echo "Please install goss from https://goss.rocks/install"
	echo "For a quick auto install run the following"
	echo "curl -fsSL https://goss.rocks/install | sh"
	exit $?
fi

docker build --tag steamcache-generic-testing .
case $1 in
  circleci)
    shift;
    mkdir -p ./reports/goss
    export GOSS_OPTS="$GOSS_OPTS --format junit"
	dgoss run $@ steamcache-generic-testing > reports/goss/report.xml
	#store result for exit code
	RESULT=$?
	#delete the junk that goss currently outputs :(
    sed -i '0,/^</d' reports/goss/report.xml
	#remove invalid system-err outputs from junit output so circleci can read it
	sed -i '/<system-err>.*<\/system-err>/d' reports/goss/report.xml
    ;;
  *)
	dgoss run $@ steamcache-generic-testing
	RESULT=$?
    ;;
esac
docker rmi steamcache-generic-testing

exit $RESULT
