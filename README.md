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
          - shubhindia/kube-dind:v1
    ```

# To-DO:
1. Add logic to handle kubeconfig so that, we can export it and switch context as we need. I am already shipping neseccary tools to communicate with kubernetes API server.
