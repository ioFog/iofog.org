# Iofogctl Platform YAML Specification

`iofogctl` allows users to deploy Edge Compute Networks ('ECNs'). The various resources which constitute an ECN are specified within YAML files for iofogctl to consume.

## Control Plane

The Control Plane is the overarching component containing specifications for [Controllers](#controller) and associated credentials.

```yaml
apiVersion: iofog.org/v1
kind: ControlPlane
metadata:
  name: buffalo
  namespace: default
spec:
  iofogUser:
    name: Foo
    surname: Bar
    email: user@domain.com
    password: g9hr823rhuoi
  controllers:
    - name: vanilla
      user: foo
      host: 30.40.50.3
      keyFile: ~/.ssh/id_rsa
    - name: kubernetes
      replicas: 2
      keyFile: ~/.ssh/id_rsa
```

| Field       | Description                                                            |
| ----------- | ---------------------------------------------------------------------- |
| IofogUser   | Credentials registered against ioFog Controller REST API.              |
| Controllers | List of Controller instances. See Controller section for more details. |

## Controller

Controllers are components of an ECN responsible for executing the workload of the Control Plane. You can define individuals Controllers for the purposes of expanding your Control Plane. Most of the time, however, you will deploy your Controllers through the Control Plane spec.

```yaml
apiVersion: iofog.org/v1
kind: Controller
metadata:
  name: alpaca
  namespace: default # Optional, iofogctl namespace to use
spec:
  # Only required for non-K8s deployment
  user: foo
  host: 30.40.50.5
  keyFile: ~/.ssh/id_rsa
  # Only required for K8s deployment
  kubeConfig: ~/.kube/config
  kubeControllerIP: 34.23.14.6 # Optional
  replicas: 1 # Optional, defaults to 1
  serviceType: LoadBalancer # Optional, defaults to "LoadBalancer"
```

| Field              | Description                                                                                                                                                              |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Name               | User-defined unique identifier of Controller instance within an iofogctl namespace. Must start and end with lowercase alphanumeric character. Can include '-' character. |
| User               | Username of remote host that iofogctl must SSH into to install Controller service.                                                                                       |
| Host               | Hostname of remote host that iofogctl must SSH into to install Controller service.                                                                                       |
| Key File           | Path to private SSH key that iofogctl must use to SSH into remote host to install Controller service.                                                                |
| Kube Config        | Path to Kubernetes configuration file that iofogctl uses to install Controller service to Kubernetes cluster.                                                            |
| Kube Controller IP | Pre-existing static IP address for Kuberneretes Load Balancer service to use.                                                                                            |
| Replicas           | Number of Controller Pods to deploy on Kubernetes cluster.                                                                                                               |
| LoadBalancer       | Kubernetes service type for Controller (one of `LoadBalancer`, `NodePort` or `ClusterIP`)                                                                                |

## Connector

Connectors are components of an ECN responsible for handling messaging between Microservices.

```yaml
apiVersion: iofog.org/v1
kind: Connector
metadata:
  name: tiger
  namespace: default # Optional, iofogctl namespace to use
spec:
  # Only required for non-K8s deployment
  user: foo
  host: 30.40.50.5
  keyFile: ~/.ssh/id_rsa
  # Only required for K8s deployment
  kubeConfig: ~/.kube/config
  replicas: 1 # Optional, defaults to 1
```

| Field       | Description                                                                                                                                                             |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Name        | User-defined unique identifier of Connector instance within an iofogctl namespace. Must start and end with lowercase alphanumeric character. Can include '-' character. |
| User        | Username of remote host that iofogctl must SSH into to install Connector service.                                                                                       |
| Host        | Hostname of remote host that iofogctl must SSH into to install Connector service.                                                                                       |
| Key File    | Path to private SSH key that iofogctl must use to SSH into remote host to install Connector service.                                                                |
| Kube Config | Path to Kubernetes configuration file that iofogctl uses to install Connector service to Kubernetes cluster.                                                            |
| Replicas    | Number of Connector Pods to deploy on Kubernetes cluster.                                                                                                               |

Note that at the moment Connector does not support specifying `ServiceType` the same way as Controller does.

## Agent

Agents are components of an ECN which run on edge nodes. They communicate with Connectors and Controllers to allow your edge nodes to host Microservices.

```yaml
apiVersion: iofog.org/v1
kind: Agent
metadata:
  name: meerkat
  namespace: default # Optional, iofogctl namespace to use
spec:
  user: foo
  host: 30.40.50.6
  keyFile: ~/.ssh/id_rsa
```

| Field | Description                                                                                                                                                         |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Name  | User-defined unique identifier of Agent instance within an iofogctl namespace. Must start and end with lowercase alphanumeric character. Can include '-' character. |
| User  | Username of remote host that iofogctl must SSH into to install Agent service.                                                                                       |
| Host  | Hostname of remote host that iofogctl must SSH into to install Agent service.                                                                                       |
| Key File    | Path to private SSH key that iofogctl must use to SSH into remote host to install Agent service.                                                                |

## Edge Compute Network

An entire ECN can be specified within a single YAML file.

Multiple resources can be incorporated into a single YAML file using `---` as a separator.

```yaml
---
apiVersion: iofog.org/v1
kind: ControlPlane
metadata:
  name: buffalo
  namespace: default
spec:
  iofogUser:
    name: Serge
    surname: Radinovich
    email: serge@edgeworx.io
    password: mysecretpw
  controllers:
    - name: alpaca-1
      user: serge
      host: 30.40.50.3
      keyFile: ~/.ssh/id_rsa
    - name: alpaca-2
      user: serge
      host: 30.40.50.4
      keyFile: ~/.ssh/id_rsa
---
apiVersion: iofog.org/v1
kind: Connector
metadata:
  name: zebra
  namespace: default
spec:
  user: serge
  host: 30.40.50.5
  keyFile: ~/.ssh/id_rsa
---
apiVersion: iofog.org/v1
kind: Agent
metadata:
  name: hippo-1
  namespace: default
spec:
  user: serge
  host: 30.40.50.6
  keyFile: ~/.ssh/id_rsa
---
apiVersion: iofog.org/v1
kind: Agent
metadata:
  name: hippo-2
  namespace: default
spec:
  user: serge
  host: 30.40.50.7
  keyFile: ~/.ssh/id_rsa
```

You can also use this approach to deploy a subset of the ECN by omitting any of the Control Plane, Connectors, or Agents sections.