#!/bin/bash
ps aux --sort=-%mem | head -n 2
echo "Above process is using highest memory."
