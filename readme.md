## 1. Install the OpenTelemetry Collector Builder

Download and set up the OpenTelemetry Collector Builder (`ocb`):

```bash
curl --proto '=https' --tlsv1.2 -fL -o ocb \
    https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/cmd%2Fbuilder%2Fv0.122.1/ocb_0.122.1_linux_amd64
chmod +x ocb
```

## 2. Build a Custom Collector

Use the installed builder to generate a custom OpenTelemetry Collector based on your configuration file:

```bash
./ocb --config ocb-cfg.yaml
```

## 3. Build and Push Docker Image

Build the Docker image for your custom OpenTelemetry Collector:

```bash
docker build -t <repo>/otelcol-dev:0.1.0 .
```

Push the image to your repository:

```bash
docker push <repo>/otelcol-dev:0.1.0
```

## 4. Label Namepace with Tenant ID

Example:

```bash
kubectl label namespace demo tenant_id=demo
```


## 5. Deploy Databases

Deploy the databases with monitoring enabled in the tenant's namespace. OpenTelemetry will collect metrics using the ServiceMonitors.


## 6. Deploy Thanos


### Deploy Minio

```bash
helm repo add minio https://operator.min.io/
````
```bash
helm upgrade --install --namespace minio-operator \
  --create-namespace minio minio/operator \
  --set operator.replicaCount=1 \
  --wait
```

#### Accessing MinIO

- Access Key: `minio`
- Secret Key: `minio123`
- Endpoint: `http://minio.minio.svc.cluster.local:80`


### Create Thanos Storage Secret

```bash
kubectl -n thanos create secret generic thanos-objstore-config --from-file=thanos-storage-config.yaml=./thanos/s3.yaml
```

### Deploy Thanos Manifests
```
kubectl create ns thanos
kubectl apply -f ./thanos/kube-thanos/manifests/

```

## 7. Deploy Opentelmetry Stack

```
 kubectl apply -f targetallocator-rbac.yaml
```

```bash
helm install opentelemetry-kube-stack -n monitoring open-telemetry/opentelemetry-kube-stack \
--set opentelemetry-operator.admissionWebhooks.certManager.enabled=false \
--set admissionWebhooks.autoGenerateCert.enabled=true \
--values=./values.yaml
```
  


## 8. Query metrics via Thanos Querier

```bash
 kubectl port-forward svc/thanos-query -n thanos 9090:9090
```
Visit http://localhost:9090 and execute a test query (e.g., up).