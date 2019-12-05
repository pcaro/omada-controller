#!/bin/sh

printf " ===== TP-LINK Omada controller Docker container =====\n"
printf " =====================================================\n"

printf "Setting up data directory..."
mkdir -p data/db data/map data/portal

rm -f ${INSTALL_DIR}data/db/journal/prealloc.*

${INSTALL_DIR}/jre/bin/java -server -Xms128m -Xmx1024m \
    -XX:MaxHeapFreeRatio=60 -XX:MinHeapFreeRatio=30 \
    -XX:+HeapDumpOnOutOfMemoryError -Deap.home=${INSTALL_DIR}/ \
    -cp ${INSTALL_DIR}/lib/*: com.tp_link.eap.start.EapLinuxMain
status=$?
printf "\n =========================================\n"
printf " Exit with status $status\n"
printf " =========================================\n"
