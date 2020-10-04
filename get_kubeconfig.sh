#!/bin/sh

echo "Getting kubeconfig from configmap"
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/gitlab-runner/configmaps/kubeconfig | jq -j ".data.kubeconfig" > /kubeconfig
