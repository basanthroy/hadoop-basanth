#!/usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Run a Hadoop command on all slave hosts.

function hadoop_usage
{
  echo "Usage: hadoop-daemons.sh [--config confdir] [--hosts hostlistfile] (start|stop|status) <hadoop-command> <args...>"
}

this="${BASH_SOURCE-$0}"
bin=$(cd -P -- "$(dirname -- "${this}")" >/dev/null && pwd -P)

# let's locate libexec...
if [[ -n "${HADOOP_PREFIX}" ]]; then
  DEFAULT_LIBEXEC_DIR="${HADOOP_PREFIX}/libexec"
else
  DEFAULT_LIBEXEC_DIR="${bin}/../libexec"
fi

HADOOP_LIBEXEC_DIR="${HADOOP_LIBEXEC_DIR:-$DEFAULT_LIBEXEC_DIR}"
# shellcheck disable=SC2034
HADOOP_NEW_CONFIG=true
if [[ -f "${HADOOP_LIBEXEC_DIR}/hdfs-config.sh" ]]; then
  . "${HADOOP_LIBEXEC_DIR}/hdfs-config.sh"
else
  echo "ERROR: Cannot execute ${HADOOP_LIBEXEC_DIR}/hdfs-config.sh." 2>&1
  exit 1
fi

if [[ $# = 0 ]]; then
  hadoop_exit_with_usage 1
fi

daemonmode=$1
shift

if [[ -z "${HADOOP_HDFS_HOME}" ]]; then
  hdfsscript="${HADOOP_PREFIX}/bin/hdfs"
else
  hdfsscript="${HADOOP_HDFS_HOME}/bin/hdfs"
fi

hadoop_error "WARNING: Use of this script to ${daemonmode} HDFS daemons is deprecated."
hadoop_error "WARNING: Attempting to execute replacement \"hdfs --slaves --daemon ${daemonmode}\" instead."

#
# Original input was usually:
#  hadoop-daemons.sh (shell options) (start|stop) (datanode|...) (daemon options)
# we're going to turn this into
#  hdfs --slaves --daemon (start|stop) (rest of options)
#
argv=(${HADOOP_USER_PARAMS[@]/start})
argv=(${argv[@]/stop})
argv=(${argv[@]/status})

${hdfsscript} --slaves --daemon "${daemonmode}" "${argv[@]}"
