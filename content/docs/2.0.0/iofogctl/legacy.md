# Legacy Commands in iofogctl

You can use legacy CLI of each component i.e Controller and Agent.

## Using Legacy Commands

To use legacy commands from iofogctl, preface any legacy command you want with:

```bash
iofogctl legacy <component> <component-name> command -n <namespace of component>
```

e.g.

```bash
iofogctl legacy agent iofog-agent config -n default
```

where I want to get the output of the config command from my agent, named iofog-agent

To determine what legacy commands you wish to use, please see the legacy cli documentation for each component at the following links:

[Agent](../reference-agent/cli-usage.html)

[Controller](../reference-controller/cli-usage.html)

<aside class="notifications contribute">
  <h3><img src="/images/icos/ico-github.svg" alt="">See anything wrong with the document? Help us improve it!</h3>
  <a href="https://github.com/eclipse-iofog/iofog.org/edit/develop/content/docs/2.0.0/iofogctl/legacy.md"
    target="_blank">
    <p>Edit this page on Github!</p>
  </a>
</aside>
