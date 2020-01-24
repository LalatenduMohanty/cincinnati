# Running Cincinnati

## Prerequisite

APP-SRE publishes the Cincinnati container images at [Quay registry](https://quay.io/repository/app-sre/cincinnati)

We need an image tag from the [Quay registry](https://quay.io/repository/app-sre/cincinnati) to use with the deployment config.

The Cincinnati deploymentconfig present in the git repository at [dist/openshift/](https://github.com/openshift/cincinnati/blob/master/dist/openshift/cincinnati.yaml)

### Steps

* Create a new namespace for Cincinnati

```shell
oc new-project cincinnati
```

* Create Cincinnati deployment

```shell
export IMAGE_TAG=<TAG>
oc new-app -f cincinnati.yaml \
  -p IMAGE_TAG=${IMAGE_TAG} \
```

* Wait for teh deployment config to rollout

```shell
oc wait --for=condition=available --timeout=5m deploymentconfig/cincinnati

```

* Create an route to the Cincinnati policy engine

Example of a yaml for an ingress route to the policy engine

```json
kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: cincinnati
  namespace: cincinnati
  labels:
    app: cincinnati-policy-engine
  annotations:
    openshift.io/host.generated: 'true'
spec:
  host: cincinnati-cincinnati.apps.ci-ln-13sjybk-d5d6b.origin-ci-int-aws.dev.rhcloud.com
  to:
    kind: Service
    name: cincinnati-policy-engine
    weight: 100
  port:
    targetPort: policy-engine
  tls:
    termination: edge
  wildcardPolicy: None
status:
  ingress:
  - conditions:
    host: cincinnati-cincinnati.apps.ci-ln-13sjybk-d5d6b.origin-ci-int-aws.dev.rhcloud.com
    routerCanonicalHostname: apps.ci-ln-13sjybk-d5d6b.origin-ci-int-aws.dev.rhcloud.com
    routerName: default
    wildcardPolicy: None
```

To get existing ingress routes, run:
```shell
oc get svc -n openshift-ingress
```