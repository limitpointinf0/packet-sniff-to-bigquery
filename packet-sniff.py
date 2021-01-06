from google.cloud import pubsub_v1
import pyshark
from datetime import datetime
import os
import json
import argparse

parser = argparse.ArgumentParser(description="Capture packets with tshark")
parser.add_argument("-i", "--interface", default="lo" , help="name of interface")
parser.add_argument("-c", "--credentials", default="credentials.json", help="path to google application credentials")
parser.add_argument("-p", "--projectid", help="id of project", required=True)
parser.add_argument("-t", "--topicid", help="id of topic", required=True)
args = parser.parse_args()

os.environ["GOOGLE_APPLICATION_CREDENTIALS"]=args.credentials
capture = pyshark.LiveCapture(interface=args.interface)
project_id = args.projectid
topic_id = args.topicid

publisher = pubsub_v1.PublisherClient( )
topic_path = publisher.topic_path(project_id, topic_id)


def to_pub_sub(packet):
    if 'IP' in packet:
        dt = str(datetime.now())
        json_pk = {
            "datetime": dt,
            "source": packet['ip'].src, 
            "destination": packet['ip'].dst
        }
        json_pk = json.dumps(json_pk)
        print(json_pk)
        future = publisher.publish(
            topic_path, 
            data=json_pk.encode("utf-8")
        )
capture.apply_on_packets(to_pub_sub)