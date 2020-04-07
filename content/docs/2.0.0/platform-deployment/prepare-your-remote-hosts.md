# Prepare Your Remote Hosts

An ioFog Edge Compute Network ('ECN') is composed of a set of ioFog Controllers and Agents. A typical ECN will have each instance of the various components deployed on a different remote host.

ECN's are deployed using `iofogctl`. The following steps will ensure that your remote hosts are ready to have `iofogctl` deploy ECN components onto them remotely.

## Add your SSH RSA Public Key to the Remote Host

`iofogctl` will SSH into your remote hosts using an RSA SSH key-pair you specify.

Add the public key of the key-pair that you intend to use with `iofogctl` to the remote host you intend to deploy ECN components onto. For example, you could run a command like this from the host you intend to use `iofogctl` from:

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub <username>@<hostname>
```

## Add the Remote Host's User to Sudo Group

`iofogctl` will need to run certain commands as sudo. In order to do this without using the root user, you must add the user you intend to use on the remote host to the sudo group. Run this command on the remote host:

```bash
usermod -aG sudo $USER
```

## Allow Sudoers to Sudo without Password

In order to prevent interruptions during `iofogctl` SSH sessions, you need to ensure that the sudoers in the remote host can run commands without having to enter a password.

You can achieve this by editing the sudoers file by first running `su visudo` on the remote host. This will open up the sudoers file for editing. Make sure this line is present in the file `%sudo ALL=(ALL) NOPASSWD:ALL`.

#### Continue with Remote Control Plane

[Next Step: Deploy Remote Control Plane](remote-control-plane.html).

#### Continue with Kubernetes Control Plane

[Next Step: Prepare your Kubernetes Cluster](kubernetes-prepare-cluster.html).

<aside class="notifications contribute">
  <h3><img src="/images/icos/ico-github.svg" alt="">See anything wrong with the document? Help us improve it!</h3>
  <a href="https://github.com/eclipse-iofog/iofog.org/edit/develop/content/docs/2.0.0/platform-deployment/remote-prepare-controller-host.md"
    target="_blank">
    <p>Edit this page on Github!</p>
  </a>
</aside>
