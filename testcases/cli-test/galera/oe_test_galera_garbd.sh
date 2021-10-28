#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   zhanglu626
# @Contact   :   m18409319968@163.com
# @Date      :   2021/10/12
# @License   :   Mulan PSL v2
# @Desc      :   A plug-in shared library file
# ############################################

source "../common/common_galera.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    galera_pre
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    garbd -d --group grabd_name -a "gcomm://0.0.0.0"
    test -n $(pgrep -f garbd)
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'garbd')
    garbd -h 2>&1 | grep 'Usage: garbd'
    CHECK_RESULT $?
    SLEEP_WAIT 3
    garbd -d -g garbd_name -a "gcomm://0.0.0.0"
    test -n $(pgrep -f garbd)
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'garbd')
    SLEEP_WAIT 3
    garbd -d -n node_name -g grabd_name --address "gcomm://0.0.0.0"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'garbd')
    garbd -d --name node_name --group grabd_name -a "gcomm://0.0.0.0"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'garbd')
    SLEEP_WAIT 3
    garbd -d -n node_name -g grabd_ggg --sst trivial --donor sst_name -a "gcomm://0.0.0.0"
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'garbd')
    SLEEP_WAIT 3
    garbd -d -n node_name -g grabd_name -l galera_zl/log1 -a "gcomm://0.0.0.0"
    kill -9 $(pgrep -f 'garbd')
    grep "node_name" galera_zl/log1
    CHECK_RESULT $?
    garbd -d -o "socket.ssl_key=galera_zl/server-key.pem;socket.ssl_cert=galera_zl/server-cert.pem;socket.ssl_ca=galera_zl/ca.pem;socket.ssl_cipher=AES128-SHA" -n garbd_node -g grabd_name -a "gcomm://0.0.0.0" -l galera_zl/log2
    kill -9 $(pgrep -f 'garbd')
    grep "options: socket.ssl_key" galera_zl/log2
    CHECK_RESULT $?
    garbd -d -c galera_zl/galera_cfg -l galera_zl/log3
    test -n $(pgrep -f garbd)
    grep "node_name" galera_zl/log3 
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'garbd')
    garbd -v 2>&1 | grep INFO
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    DNF_REMOVE galera
    rm -rf galera_zl
    LOG_INFO "Finish environment cleanup."
}

main $@
