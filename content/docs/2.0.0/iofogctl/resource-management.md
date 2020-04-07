# iofogctl Resource Management

## Deploying New Edge Compute Networks

`iofogctl` allows you to deploy an entire ECN from a single command and YAML file.

```bash
iofogctl deploy -f ecn.yaml
```

`iofogctl` also allows you to deploy indvidiual components of an ECN using the same command but different YAML files.

```bash
iofogctl deploy -f controlplane.yaml
iofogctl deploy -f controller.yaml
iofogctl deploy -f agent.yaml
iofogctl deploy -f agentConfig.yaml
iofogctl deploy -f application.yaml
```

`iofogctl` deploy commands are designed to be idempotent. Feel free to spam these commands as much as you like - the end result will always be the same. If anything goes wrong with your deployment, run the relevant deploy commands again and you should be good to go.

Specifications of the ioFog platform YAML types can be found [here](../reference-iofogctl/reference-control-plane.html).

Specifications of the ioFog application YAML types can be found [here](../reference-iofogctl/reference-application.html).

## Delete Components of Edge Compute Networks

You can delete resources that you have deployed to free up any associated infrastructure. Deleting resources like Control Planes, Controllers and Agents will cause any corresponding daemons to be terminated on the remote hosts.

```bash
iofogctl delete controller alpaca-1
iofogctl delete agent kiwi-1
iofogctl delete application health-care-app
iofogctl delete microservice health-case-ui
```

To undo a deletion, you can simply re-run the corresponding deploy command for the deleted resource.

If you want to wipe an entire ECN, you can run:

```bash
iofogctl delete all
```

or, if you also want to delete the namespace, you can run:

```bash
iofogctl delete namespace zoo-1 --force
```

<aside class="notifications contribute">
  <h3><img src="/images/icos/ico-github.svg" alt="">See anything wrong with the document? Help us improve it!</h3>
  <a href="https://github.com/eclipse-iofog/iofog.org/edit/develop/content/docs/2.0.0/iofogctl/resource-management.md"
    target="_blank">
    <p>Edit this page on Github!</p>
  </a>
</aside>
