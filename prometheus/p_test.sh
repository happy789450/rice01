#!/bin/bash

# 模拟脚本输出一个指标值
METRIC_VALUE=$(date +%s)  # 替换为你的实际逻辑

# 推送到 Pushgateway
cat <<EOF | curl --data-binary @- http://localhost:9091/metrics/job/my_script/instance/example
# TYPE my_script_result gauge
my_script_result $METRIC_VALUE
EOF
