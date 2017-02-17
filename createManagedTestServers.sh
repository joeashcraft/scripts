#!/bin/bash
rack servers instance delete --name "centos7.test.tbr0" --profile "cloudlaunch"
rack servers instance create --name "centos7.test.tbr0" \
--flavor-id "general1-1" \
--image-id "f2db6fd7-1e40-41f1-9ac0-ad8d1dfd7651" \
--networks "00000000-0000-0000-0000-000000000000,11111111-1111-1111-1111-111111111111" \
--keypair "tbr0-key" \
--profile "cloudlaunch"

rack servers instance delete --name "ubuntu14.test.tbr0" --profile "cloudlaunch"
rack servers instance create --name "ubuntu14.test.tbr0" \
--flavor-id "general1-1" \
--image-id "3f08e502-769c-44c0-b573-d1901f2f5b98" \
--networks "00000000-0000-0000-0000-000000000000,11111111-1111-1111-1111-111111111111" \
--keypair "tbr0-key" \
--profile "cloudlaunch"

rack servers instance delete --name "ubuntu16.test.tbr0" --profile "cloudlaunch"
rack servers instance create --name "ubuntu16.test.tbr0" \
--flavor-id "general1-1" \
--image-id "821ba5f4-712d-4ec8-9c65-a3fa4bc500f9" \
--networks "00000000-0000-0000-0000-000000000000,11111111-1111-1111-1111-111111111111" \
--keypair "tbr0-key" \
--profile "cloudlaunch"
