#!/usr/bin/env bash
set -ex
export PATH="/snap/bin:$PATH"

export NAMESPACE="polygon"
export BOR_PV_NAME=`kubectl -n $NAMESPACE get pvc data-bor-0 -o=jsonpath='{.spec.volumeName}{"\n"}'`
export HEIMDALL_PV_NAME=`kubectl -n $NAMESPACE get pvc data-heimdall-0 -o=jsonpath='{.spec.volumeName}{"\n"}'`
export DATA_SUFFIX=`date +%F`

function stop_bor() {
  kubectl -n $NAMESPACE scale sts bor --replicas=0
}

function stop_heimdall() {
  kubectl -n $NAMESPACE scale sts heimdall --replicas=0
  # ToDo: improve sleep to wait
  sleep 60s
}

function mount_bor_data_from_pv() {
  gcloud compute instances attach-disk `hostname` --disk $BOR_PV_NAME --zone=europe-west4-a
  sudo mkdir -p /mnt/disks/bor
  sudo mount -o discard,defaults /dev/sdb /mnt/disks/bor
}

function snapshot_bor() {
  cd /mnt/disks/snapshots/
  rm -rf bor-*.tgz
  tar -C /mnt/disks/bor/bor/chaindata/ -czf bor-$DATA_SUFFIX.tgz .
}

function put_bor_data_to_gcs() {
  for region in eu as1 us; do
    bucket_name="polygon-snapshots-${region}"
    gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp /mnt/disks/snapshots/bor-$DATA_SUFFIX.tgz gs://$bucket_name/bor-$DATA_SUFFIX.tgz
    gsutil acl ch -u AllUsers:R gs://$bucket_name/bor-$DATA_SUFFIX.tgz
  done
}

function mount_heimdall_data_from_pv() {
  gcloud compute instances attach-disk `hostname` --disk $HEIMDALL_PV_NAME --zone=europe-west4-a
  sudo mkdir -p /mnt/disks/heimdall
  sudo mount -o discard,defaults /dev/sdc /mnt/disks/heimdall
}

function snapshot_heimdall() {
  cd /mnt/disks/snapshots/
  rm -rf heimdall-*.tgz
  tar -C /mnt/disks/heimdall/data/ -czvf heimdall-$DATA_SUFFIX.tgz .
}

function put_heimdall_data_to_gcs() {
  for region in eu as1 us; do
    bucket_name="polygon-snapshots-${region}"
    gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp /mnt/disks/snapshots/heimdall-$DATA_SUFFIX.tgz gs://${bucket_name}/heimdall-${DATA_SUFFIX}.tgz
  done
}

function start_bor() {
  umount /mnt/disks/bor
  gcloud compute instances detach-disk `hostname` --disk $BOR_PV_NAME --zone=europe-west4-a
  kubectl -n $NAMESPACE scale sts bor --replicas=1
}

function start_heimdall() {
  umount /mnt/disks/heimdall
  gcloud compute instances detach-disk `hostname` --disk $HEIMDALL_PV_NAME --zone=europe-west4-a
  kubectl -n $NAMESPACE scale sts heimdall --replicas=1
}

# Main
gcloud auth activate-service-account --key-file=/sa.json

stop_bor
stop_heimdall
mount_bor_data_from_pv
mount_heimdall_data_from_pv
snapshot_bor
snapshot_heimdall
start_bor
start_heimdall
put_bor_data_to_gcs
put_heimdall_data_to_gcs
