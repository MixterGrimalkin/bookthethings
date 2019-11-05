#!/usr/bin/env bash
RESP=`curl http://localhost:3000/auth/login -d "email=$1&password=$2"`
echo $RESP