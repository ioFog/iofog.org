# Distributed Applications

ioFog is a platform for running distributed applications on Edge Compute Networks. A distributed application is made up of some number of microservices.

You can specify distributed applications in YAML through iofogctl's [Application kind](../reference-iofogctl/reference-application.html#application). You can then deploy an entire distributed application through iofogctl by using this specification:

```bash
iofogctl deploy -f application.yaml
```

You can also deploy individual microservices if you wish. The iofogctl [Microservice kind](../reference-iofogctl/reference-application.html#microservices) allows us to do this.

```bash
iofogctl deploy -f microservice.yaml
```

The rest of this section will cover how you can manage your distributed applications and microservices after you have deployed them.

<aside class="notifications contribute">
  <h3><img src="/images/icos/ico-github.svg" alt="">See anything wrong with the document? Help us improve it!</h3>
  <a href="https://github.com/eclipse-iofog/iofog.org/edit/develop/content/docs/2.0.0/microservices/applications.md"
    target="_blank">
    <p>Edit this page on Github!</p>
  </a>
</aside>
