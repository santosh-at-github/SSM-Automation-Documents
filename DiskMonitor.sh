#!/bin/bash

EbsVolId=$1
Threshold=$2
DevName=$3

if [[ $# -ne 3 ]]; then
  echo "Usages: $0 <EBS Volume ID> <Threshold> <Name of the partition or volume (in case of no partition) which should be monirored>"
  echo -e "Example:\n\t$0 vol-000fe5ad780de131e 75 /dev/xvda1"
  exit 1
fi
DiskUse=$(df | grep $DevName | awk '{print $(NF -1)}')
DiskUse=${DiskUse//%/}
if [[ $DiskUse -ge $Threshold ]]; then
   DiskSize=$(df | grep $DevName | awk '{print $2}')
   NewDiskSize=$(echo "(($DiskSize * 5)/4)/(1024*1024)"|bc ) # Increase disk size by 25% (approx)
   aws ssm start-automation-execution --document-name "EBS-Volume-Modify" --parameters "volumeId=$EbsVolId,desiredVolumeSize=$NewDiskSize"
fi
