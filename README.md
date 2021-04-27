# bbb_stresstest_with_terraform
Deploy many instances on OVHcloud Public Cloud Instances to test BBB performances

Use the following command line to launch deployment :

```bash
$ terraform apply \
  -var="ovh_region='["GRA11","BHS5"]' \                                   # Default GRA7 and BHS5, make sure those regions are available on your project
  -var="bbb_fqdn=bbb.domain.tld" \                                        # URL of your BBB server
  -var="bbb_secret=a1b2c3" \                                              # BBB secret currently configured on your server, run "$ bbb-conf --secret" to display it
  -var="image=Ubuntu 20.10" \                                             # Linux distribution used for deployement, default is Ubuntu 20.10
  -var="flavor=c2-30-flex" \                                              # Instances Flavor (CPU,RAM,Disk config), default is c2-30-flex
  -var="nb_instances=4" \                                                 # Total number of instances spreaded across all regions, default is 4
  -var='params={"duration":600,"listen_only":10,"micro":5,"webcam":1}' \  # Parameters of Stress Test (duration, listen_only, micro, webcam), default is 600, 10, 5, 1
  -var="keypair_name=keypair-with-terraform" \                            # Keypair name stored in Openstack
  -var="public_key=~/.ssh/id_rsa.pub"                                     # Public Key used by Openstack
