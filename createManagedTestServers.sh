#!/bin/bash
rack servers instance create --name "centos7.test.tbr0" \
--flavor-id "general1-1" \
--image-id "f2db6fd7-1e40-41f1-9ac0-ad8d1dfd7651" \
--networks "00000000-0000-0000-0000-000000000000,11111111-1111-1111-1111-111111111111" \
--keypair "tbr0-key" \
--profile "cloudlaunch"
