#!/usr/bin/env bash
set -ex
export PATH="/snap/bin:$PATH"

BACKUP_PATH="/backup"
BOR_DATA_PATH="/root/.bor/data/bor/chaindata"
BOR_SNAPSHOT_NAME="bor.tgz"
HEIMDALL_DATA_DIR="/root/.heimdalld/data"
HEIMDALL_SNAPSHOT_NAME="heimdall.tgz"
# CONTAINER_NAME="bsc"
# SNAPSHOT_NAME="geth.tar"
# SNAPSHOT_PATH="${BACKUP_PATH}/${SNAPSHOT_NAME}"
# DATA_PATH="/data"

function drop_old_snapshot() {
    rm -f $BACKUP_PATH/*.tgz
}

function stop_bor() {
    systemctl stop bor
}

function stop_heimdall() {
    systemctl stop heimdalld
}

function start_bor() {
    systemctl start bor
}

function start_heimdall() {
    systemctl start heimdalld
}

function make_bor_snapshot() {
    sync
    tar -C ${BOR_DATA_PATH} -czf ${BACKUP_PATH}/${BOR_SNAPSHOT_NAME} .
}

function make_heimdall_snapshot() {
    sync
    tar -C ${HEIMDALL_DATA_DIR} -czf ${BACKUP_PATH}/${HEIMDALL_SNAPSHOT_NAME} .
}

function upload_snapshot() {
    # gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp ${SNAPSHOT_PATH} gs://${1}/${SNAPSHOT_NAME}
    # gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp /mnt/disks/snapshots/heimdall-$DATA_SUFFIX.tgz gs://${bucket_name}/heimdall.tgz
    gsutil -o GSUtil:parallel_composite_ulspload_threshold=150M cp ${BACKUP_PATH}/${BOR_SNAPSHOT_NAME} gs://${1}/
    gsutil -o GSUtil:parallel_composite_ulspload_threshold=150M cp ${BACKUP_PATH}/${HEIMDALL_SNAPSHOT_NAME} gs://${1}/
    sudo -u ubuntu gsutil acl set -R -a public-read  gs://${1}/${BOR_SNAPSHOT_NAME}
    sudo -u ubuntu gsutil acl set -R -a public-read gs://${1}/${HEIMDALL_SNAPSHOT_NAME}
}

# Main
drop_old_snapshot
stop_bor
make_bor_snapshot
start_bor
stop_heimdall
make_heimdall_snapshot
start_heimdall

for region in eu as1 us; do
    bucket_name="polygon-snapshots-${region}"
    upload_snapshot $bucket_name &
done
