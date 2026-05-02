#!/usr/bin/env bash
#
# This is the sample script to generate a FMP capsule.
#   - Script should work with EDK-II repository.
#
# Copyright (c) 2026, Jason Lin. All rights reserved.<BR>
#
# SPDX-License-Identifier: BSD-3-Clause
#

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Common environment variables for EDK-II build.
export WORKSPACE=$SCRIPT_DIR
export EDK_II_PATH=$WORKSPACE/edk2
export EDK_TOOLS_PATH=$EDK_II_PATH/BaseTools

# Capsule environment variables.
export FMP_CAPSULE_GUID=d70a1fe1-4fc5-47a0-bb25-2fdda093cf83
export FMP_CAPSULE_VER=0x1
export FMP_CAPSULE_LSV=0x1
export SIGNING_TOOL_PATH=/usr/bin
export ROOT_PUB_KEY=$EDK_TOOLS_PATH/Source/Python/Pkcs7Sign/TestRoot.pub.pem
export INTERMEDIATE_PUB_KEY=$EDK_TOOLS_PATH/Source/Python/Pkcs7Sign/TestSub.pub.pem
export SIGNER_PRIV_KEY=$EDK_TOOLS_PATH/Source/Python/Pkcs7Sign/TestCert.pem
export FMP_CAPSULE_PAYLOAD=$WORKSPACE/Payload.bin
export FMP_CAPSULE_FILE=$WORKSPACE/Capsule.cap

# Setup the EDK-II Build Environment.
cp -r $EDK_II_PATH/Conf $WORKSPACE/Conf
source $EDK_II_PATH/edksetup.sh

# Build the EDK-II BaseTools.
make -C $EDK_TOOLS_PATH

# Build the Capsule.
GenerateCapsule \
  --encode \
  -v \
  --capflag PersistAcrossReset \
  --capflag InitiateReset \
  --guid $FMP_CAPSULE_GUID \
  --fw-version $FMP_CAPSULE_VER \
  --lsv $FMP_CAPSULE_LSV \
  --signing-tool-path=$SIGNING_TOOL_PATH \
  --signer-private-cert=$SIGNER_PRIV_KEY \
  --other-public-cert=$INTERMEDIATE_PUB_KEY \
  --trusted-public-cert=$ROOT_PUB_KEY \
  -o $FMP_CAPSULE_FILE \
  $FMP_CAPSULE_PAYLOAD
