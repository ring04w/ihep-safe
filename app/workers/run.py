##!/usr/bin/env python
from openvas_lib import VulnscanManager,VulnscanException
from threading import Semaphore
from functools import partial
from xml.etree import ElementTree
import base64
import datetime
import os
import sys,re
import subprocess
import time
import random

openvas_ip=sys.argv[1]
admin_name=sys.argv[2]
admin_password=sys.argv[3]
result_dir=sys.argv[4]
manager= VulnscanManager(openvas_ip,admin_name,admin_password)
def my_print_status(i):
    print str(i),
    sys.stdout.flush()
def write_report(report_id,ip):
    global manager
    global result_dir
    try:
        report=manager.get_report_html(report_id)
    except Exception,e:
        print e
        return
    else:
        fout=open(result_dir+"/"+ip+".html","wb")
        fout.write(base64.b64decode(report.find("report").text))
        fout.close()
    try:
        report=manager.get_report_xml(report_id)
    except Exception,e:
        print e
        return
    else:
        fout=open(result_dir+"/"+ip+".xml","wb")
        fout.write(ElementTree.tostring(report,encoding='utf-8',method='xml'))
        fout.close()
def run(ip):
    global manager
    Sem =Semaphore(0)
    scan_id,target_id=manager.launch_scan(
            target=ip,
            profile="Full and fast",
            callback_end=partial(lambda x:x.release(),Sem),
            callback_progress=my_print_status
            )
    Sem.acquire()
    report_id=manager.get_report_id(scan_id)
    write_report(report_id,ip)
    try:
        manager.delete_scan(scan_id)
        manager.delete_target(target_id)
    except Exception,e:
        print e
        return
run(sys.argv[5])
