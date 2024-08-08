#!/usr/bin/env python3

import sys, re

file = open(sys.argv[1], "r")
for line in file.readlines():
  if "Mbit" in line:
    values = line.replace('M', ' M').split()
    print(round(float(values[0])/1000, 10), "Gbits/sec")    
  if "Gbit" in line:
    print(line.replace('G', ' G'), end='')
