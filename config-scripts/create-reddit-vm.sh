gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family reddit-full \
  --machine-type=f1-micro \
  --zone=europe-west1-b \
  --restart-on-failure \
  --tags puma-server

