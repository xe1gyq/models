<!--- 40. Quick Start Scripts -->
## Quick Start Scripts

| Script name | Description |
|-------------|-------------|
| [int8_accuracy.sh](int8_accuracy.sh) | Tests accuracy using the COCO dataset in the TF Records format. |
| [int8_inference.sh](int8_inference.sh) | Run inference using synthetic data and outputs performance metrics. |
| [icx_realtime_inference.sh](icx_realtime_inference.sh) | Realtime inference script for ICX that uses numactl to run multiple instances using 4 cores per instance. |
| [icx_throughput_inference.sh](icx_throughput_inference.sh) | Throughput inference script for ICX that uses numactl to run multiple instances using the cores on each socket per instance. |

These quickstart scripts can be run in different environments:
* [Bare Metal](#bare-metal)
* [Docker](#docker)
