#!/usr/bin/env bash
#
# Copyright (c) 2020 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This script preprocesses the validation images for the COCO Dataset to create
# TF records files. The raw validation images and annotations must be downloaded
# prior to running this script (https://cocodataset.org/#download).
#
# The following vars need to be set:
#   VAL_IMAGE_DIR: Points to the raw validation images (extracted from val2017.zip)
#   ANNOTATIONS_DIR: Points to the annotations (extracted from annotations_trainval2017.zip)
#   OUTPUT_DIR: Path where the TF records file will be written
#
# This is intended to be used with the create_coco_tf_record.py script from the
# TensorFlow Model Garden, commit 1efe98bb8e8d98bbffc703a90d88df15fc2ce906.
#
# NOTE: This pre-processes the validation images only


# Verify that the a directory exists for the raw validation images
if [[ ! -d "${VAL_IMAGE_DIR}" ]]; then
  echo "ERROR: The VAL_IMAGE_DIR (${VAL_IMAGE_DIR}) does not exist. This var needs to point to the raw coco validation images."
fi

# Verify that the a directory exists for the annotations
if [[ ! -d "${ANNOTATIONS_DIR}" ]]; then
  echo "ERROR: The ANNOTATIONS_DIR (${ANNOTATIONS_DIR}) does not exist. This var needs to point to the coco annotations directory."
fi

# Verify that we have the path to the tensorflow/models code
if [[ ! -d "${TF_MODELS_DIR}" ]]; then
  echo "ERROR: The TF_MODELS_DIR var needs to be defined to point to a clone of the tensorflow/models git repo"
  exit 1
fi

cd ${TF_MODELS_DIR}/research
export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim

# Create empty dir and json for train/test image preprocessing, so that we don't require
# the user to also download train/test images when all that's needed is validation images.
EMPTY_DIR=$(pwd)/empty_dir
EMPTY_ANNOTATIONS=${ANNOTATIONS_DIR}/empty.json
mkdir -p ${EMPTY_DIR}
echo "{ \"images\": {}, \"categories\": {}}" > ${EMPTY_ANNOTATIONS}

cd ${TF_MODELS_DIR}/research/object_detection/dataset_tools
python create_coco_tf_record.py --logtostderr \
      --train_image_dir="${EMPTY_DIR}" \
      --val_image_dir="${VAL_IMAGE_DIR}" \
      --test_image_dir="${EMPTY_DIR}" \
      --train_annotations_file="${EMPTY_ANNOTATIONS}" \
      --val_annotations_file="${ANNOTATIONS_DIR}/instances_val2017.json" \
      --testdev_annotations_file="${EMPTY_ANNOTATIONS}" \
      --output_dir="${OUTPUT_DIR}"

# remove dummy directory and annotations file
rm -rf ${EMPTY_DIR}
rm -rf ${EMPTY_ANNOTATIONS}

# since we only grab the validation dataset, the TF records files for train
# and test images are size 0. Delete those to prevent confusion.
rm -f ${OUTPUT_DIR}/coco_testdev.record
rm -f ${OUTPUT_DIR}/coco_train.record

echo "TF records in the output directory:"
ls -l ${OUTPUT_DIR}
