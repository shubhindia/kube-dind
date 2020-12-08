# kube-dind
This is something I started, so that gitlab runner can talk to kubernetes API server to do deployments. 

# How-to:
1. In your gitlab-ci.yaml use this image as a service rather than docker:dind
    ```
        image: docker:latest
        variables:
          DOCKER_HOST: tcp://127.0.0.1:2375
        stage: build
        services:
          - shubhindia/kube-dind:v2
        script: 
          - sh /get_kubeconfig.sh
          - export KUBECONFIG=/kubeconfig
          - kubectx <cluster name>

    ```


