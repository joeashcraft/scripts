#!/bin/bash
for i in `cat cloudflareips.txt`; do ./lb_add_access_list.sh $i; sleep 10; done;
