# Volume Management

Often your Microservices will require some external data to be mounted into their container environments.

With iofogctl, you can push directories to your Agents so that they can be mounted into Microservice containers as volumes. To do this, you can specify a Volume in YAML like so:

```yaml
apiVersion: iofog.org/v2
kind: Volume
spec:
  name: secret
  source: /tmp/
  destination: /tmp/secrets/
  permissions: 666
  agents:
    - name: agent-1
    - name: agent-2
```

To push the data to your Agents, you run:

```bash
iofogctl deploy -f volume.yaml
```

With the above example, the `/tmp/` directory and all of its subdirectories will be pushed to `/tmp/secrets/` in `agent-1` and `agent-2`.

Once the Volume has been deployed, you can deploy Microservices that depend on it.

Volumes can be listed, described, and deleted like all other iofogctl resources.

<aside class="notifications contribute">
  <h3><img src="/images/icos/ico-github.svg" alt="">See anything wrong with the document? Help us improve it!</h3>
  <a href="https://github.com/eclipse-iofog/iofog.org/edit/develop/content/docs/2.0.0/agent-management/volumes.md"
    target="_blank">
    <p>Edit this page on Github!</p>
  </a>
</aside>
