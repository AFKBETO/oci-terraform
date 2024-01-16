# compartment-vars.tf
#Required
variable "compartment_id" {
  description = "Compartment OCID"
  type        = string
}
############################################
# VCN
############################################

variable "vcn1" {
  description = "K3S VCN"
  default = {
    cidr_blocks : ["10.0.0.0/16"]
    dns_label : "k3svcn"
    display_name : "K3S_VCN"
  }
}

############################################
# Public Subnet, Route Table, and Internet Gateway
############################################

variable "subnetA_pub" {
  description = "Public subnet for K3S VCN"
  default = {
    cidr_block : "10.0.0.0/24"
    display_name : "K3S_subnetA_pub"
    dns_label : "subnetpub"
    is_public : true
    route_table : {
      display_name = "routeTable-Apub"
      description  = "routeTable-Apub"
    }
  }
}

variable "internet_gateway_A" {
  description = "Internet Gateway for K3S VCN"
  default = {
    display_name : "K3S_IG_A"
    ig_destination = "0.0.0.0/0"
  }
}

############################################
# Security List
############################################

variable "k3s_vcn_security_list" {
  description = "Security List for K3S nodes"
  default = {
    display_name : "K3S_Security_List"
    ingress_security_rules : [
      {
        description : "HA with embedded etcd"
        protocol : "6"
        source : "10.0.0.0/24"
        destination_port_range : {
          min : 2379
          max : 2380
        }
      },
      {
        description : "K3s supervisor and Kubernetes API Server"
        protocol : "6"
        source : "10.0.0.0/24",
        destination_port_range : {
          min : 6443
          max : 6443
        }
      },
      {
        description : "Kubelet metric"
        protocol : "6"
        source : "10.0.0.0/24"
        destination_port_range : {
          min : 10250
          max : 10250
        }
      }
    ]
    egress_security_rules : [
      {
        description : "Allow all traffics between nodes"
        protocol : "all"
        destination : "10.0.0.0/24"
      }
    ]
  }
}

############################################
# Compute Instance
############################################

variable "ic_pub_vm_A" {
  description = "K3S-Master"
  default = {
    display_name : "K3S-Master"
    create_vnic_details : {
      assign_public_ip : true
      hostname_label : "k3s-master"
    }
    availability_domain : "LxsD:EU-PARIS-1-AD-1"
    image_ocid : "ocid1.image.oc1.eu-paris-1.aaaaaaaaypabo6tq62r7qhvt6q2ze2q7x76ezjfag3mkeritdvldos476d5q"
    shape : {
      name          = "VM.Standard.A1.Flex"
      ocpus         = 2
      memory_in_gbs = 12
    }
	
	boot_volume : {
		size_in_gbs = 50
		vpus_per_gb = 20
	}
  }
}

variable "ic_pub_vm_B" {
  description = "K3S-Worker"
  default = {
    display_name : "K3S-Worker"
    create_vnic_details : {
      assign_public_ip : true
      hostname_label : "k3s-worker"
    }
    availability_domain : "LxsD:EU-PARIS-1-AD-1"
    image_ocid : "ocid1.image.oc1.eu-paris-1.aaaaaaaaypabo6tq62r7qhvt6q2ze2q7x76ezjfag3mkeritdvldos476d5q"
    shape : {
      name          = "VM.Standard.A1.Flex"
      ocpus         = 2
      memory_in_gbs = 12
    }
	boot_volume : {
		size_in_gbs = 50
		vpus_per_gb = 20
	}

  }
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type 	  = string
}
