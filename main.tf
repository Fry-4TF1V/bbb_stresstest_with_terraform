locals {
  server_names = {
    for i in range(var.nb_instances):
    "stresstest_${i}" => element(tolist(var.ovh_region), i)
  }
}

# Import SSH Public Key
resource openstack_compute_keypair_v2 keypair {
  for_each   = var.ovh_region
  name       = var.keypair_name
  public_key = file(var.public_key)
  region     = each.value
}

# Create a BBB StressTest server on PCI
resource openstack_compute_instance_v2 bbb_stresstest_server {
  for_each         = local.server_names
  region           = each.value
  name             = each.key
  image_name       = var.image
  flavor_name      = var.flavor
  key_pair         = var.keypair_name
  network {
    name      = "Ext-Net"
  }
}

# Run the BBB StressTest install script inside the instance
resource null_resource install_bbb_stresstest {
  for_each     = local.server_names
  triggers     = {
      ids      =  openstack_compute_instance_v2.bbb_stresstest_server[each.key].id
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     =  openstack_compute_instance_v2.bbb_stresstest_server[each.key].access_ip_v4
    }

    inline = [
      "sudo apt update -y && sudo apt upgrade -y",
      "cd /tmp",
      "git clone https://github.com/openfun/bbb-stress-test.git",
      "sudo apt install make -y",
      "cd /tmp/bbb-stress-test/",
      "sudo add-apt-repository universe -y",
      "sudo apt update",
      "sudo apt install docker-compose -y",
      "sudo make bootstrap",
      "sed -i 's/BBB_URL=.*/BBB_URL=https:\\/\\/${var.bbb_fqdn}\\/bigbluebutton\\//g' .env",
      "sed -i 's/BBB_SECRET=.*/BBB_SECRET=${var.bbb_secret}/g' .env",
      "sed -i 's/BBB_MEETING_ID=.*/BBB_MEETING_ID='$(sudo make list-meetings | grep participants | head -n 1 | awk '{print $3}')'/g' .env",
      "sed -i 's/BBB_TEST_DURATION=.*/BBB_TEST_DURATION=${var.params.duration}/g' .env",
      "sed -i 's/BBB_CLIENTS_LISTEN_ONLY=.*/BBB_CLIENTS_LISTEN_ONLY=${var.params.listen_only}/g' .env",
      "sed -i 's/BBB_CLIENTS_MIC=.*/BBB_CLIENTS_MIC=${var.params.micro}/g' .env",
      "sed -i 's/BBB_CLIENTS_WEBCAM=.*/BBB_CLIENTS_WEBCAM=${var.params.webcam}/g' .env",
      # Add --no-sandbox in lib/stress-test.js requested by sudo
      "sed -i '/\"--mute-audio\",/a\\\n        \"--no-sandbox\",\n' lib/stress-test.js",
      "sudo make stress",
    ]
  }
}
