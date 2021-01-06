# Packet Sniff to Bigquery
Sniff packets on a NIC and send to Big Query via Cloud Pub/Sub and Cloud Functions

## How To Start the Project
- Step 1: Run the following commands to create the necessary services. 
```bash
terraform init
terraform plan
terraform apply
```  

- Step 2: In the GCP console, go to Cloud Functions and create a function configured as follows:
    - Trigger Type: Cloud Pub/Sub
    - Topic: packets
    - Runtime: Python 3.7
    - Entry Point: pubsub_to_bigq
    - Source Code: ZIP from Cloud Storage > pstobq (bucket) > pstobq.zip
    
- Step 3: Run the following commands on the provisioned VM
```bash
scp ./packet-sniff.py `terraform output sender-ip`:~
ssh `terraform output sender-ip`
sudo pip3 install pyshark
sudo pip3 install google-cloud-pubsub
sudo python3 packet-sniff.py -p [PROJECT ID] -t [TOPIC ID]
ping localhost
```  

## Sources
[Copy data from Pub/Sub to BigQuery](https://medium.com/@milosevic81/copy-data-from-pub-sub-to-bigquery-496e003228a1)

## License

[MIT](https://choosealicense.com/licenses/mit/)
