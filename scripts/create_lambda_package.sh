#!/bin/bash
cd src
pip install --target ./package boto3
cd package
zip -r9 ../../function.zip .
cd ..
zip -g ../function.zip lambda_function.py
cd ..