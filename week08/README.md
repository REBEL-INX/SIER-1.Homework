# Week 8 Homework - README

## 1 Q & A

### What is the difference between high availability and fault tolerance? Which is best to strive for?

High availability is about minimizing downtime when something fails. Fault tolerance means the system continues operating with zero interruption even when a component fails. HA is the practical standard most cloud architectures aim for. True fault tolerance is more expensive and is usually reserved for mission-critical systems.

### Explain the difference between autoscaling and elasticity. What is vertical and horizontal autoscaling? Is one better? Are they feasible on prem?

Elasticity is the system's ability to scale up and down based on demand. Autoscaling is the mechanism that delivers elasticity, which are the rules and policies that actually trigger the scaling.

Vertical scaling means giving an existing machine more resources, more CPU or more RAM. It has a hard ceiling and often requires downtime to resize. Horizontal scaling means adding more machines. There is no real ceiling and no downtime to scale, which is how cloud is designed to work.

Horizontal scaling is generally better in the cloud. Vertical scaling is sometimes the only option for legacy apps that cannot be distributed. On prem, vertical scaling is feasible but limited by physical hardware. Horizontal scaling is possible but painful, it requires physical servers, rack space, and procurement time that the cloud makes nearly instant.

### Explain what the difference between managed and unmanaged instance groups is.

Managed instance groups use the capacity of the cloud to auto-heal, auto-scale, and update on the fly. All VMs come from the same instance template. Unmanaged instance groups have more flexibility, fewer features, and more control. VMs can be different from each other, making them useful for legacy apps that cannot be distributed.

### Explain the different use cases for health checks used by applications (in instance groups) and health checks used by load balancers. Can they be the same? Are they different API calls? Should they be the same?

A health check sends an actual probe to an instance on a specific port or path and waits for a response. Depending on the response the instance is marked healthy or unhealthy. The load balancer health check and the MIG health check operate at different layers of responsibility. The load balancer health check only decides whether a VM should receive traffic. If it fails, the VM stays running but goes dark. The MIG application health check decides whether a VM should continue to exist. If it fails, the VM is replaced through autohealing.

They can technically point to the same endpoint, but they are configured separately and are different API resources in GCP. They should not share the same thresholds because they have different outcomes. The load balancer might pull traffic from a struggling VM quickly while the MIG should wait longer before replacing it, since a VM that is still booting should not be immediately terminated.

### Explain in a few sentences what the 3-tier architecture is and how it relates to what you are learning.

In cloud computing, 3-tier architecture is a way of organizing an application into three layers, each with a different job. These tiers talk to each other in order: the user interacts with the front end or website, the front end asks the application layer to do something, and the application layer fetches or stores data in the database. Keeping them separate makes the system easier to scale, secure, and update. In GCP, the load balancer sits between tier 1 and tier 2, and the MIG of VMs sits on tier 2 and can auto-heal, auto-scale, and update on the fly based on demand.

---

## 2 Runbook

Goal is to spin up a fully configured Managed Instance Group in GCP console with autoscaling and autohealing enabled, distributed across multiple zones in us-central1.

### Prerequisites

- GCP project with Compute Engine API enabled
- VPC and subnet in `us-central1` (or use default VPC)
- Compute Admin IAM role

---

### Step 1: Create a Health Check

Health check must exist before the MIG so autohealing has something to reference.

**Compute Engine -> Health Checks -> Create**

- Name: `week8-health-check`
- Protocol: `HTTP` | Port: `80` | Path: `/`
- Check interval: `10s` | Unhealthy threshold: `3`

---

### Step 2:  Create an Instance Template

**Compute Engine -> Instance Templates -> Create**

- Name: `weekgr8-template`
- Machine type: `n2-standard-2`
- Boot disk: CentOS Stream 10, `100 GB`
- Network: your VPC or default
- Network tag: `http-server`

---

### Step 3:  Create the Managed Instance Group

**Compute Engine -> Instance Groups > Create -> New managed instance group (stateless)**

- Name: `week8-mig`
- Template: `weekgr8-template`
- Location: **Multiple zones** | Region: `us-central1` | leave zones as default
- Autoscaling: **On** | Signal: CPU | Target: `60%` | Min: `2` | Max: `5`
- Autohealing: select `week8-health-check` | Initial delay: `300s`

Click **Create**.

---

### Step 4:  Verify Multi-Zone Distribution

**Compute Engine -> Instance Groups -> week8-mig -> Instances tab**

Confirm instances appear in different zones (`us-central1-a`, `us-central1-b`, `us-central1-c`). Multi-zone is set at creation and cannot be changed after the fact.

---
 

### Critical Notes

- Health check must be created before the MIG. Autohealing can't be configured without one

- Set initial delay high enough to cover startup script runtime. Too low and the MIG will replace instances that are still booting

- Multi-zone location is immutable after creation

---

## 3 Terraform

### Explain the mandatory (required) arguments for a VM in terraform

Mandatory arguemts for configuring a VM in terraform:

- name
- machine_type
- boot_disk
- network_interface
  
### Explain how to output the internal and external IP addresses of the provisioned VM and how you figured this out

- Adding an output block to the configuration exposes information about the infrastructure on the command line, in HCP Terraform, and in other Terraform configurations.

- In the outputs.tf file, add 2 resource blocks, one for internal IP and another for the external IP. You can find these in the Terraform Developer Registry.

### Choose 2 non-required arguments and give an explanation for both (do not copy and paste the reference material)

Optional arguments for configuring a VM in terraform:

- metadata_startup_script (The VM may not need a startup script if it is connecting to a resource that isn't on the public internet)

- deletion_protection (The VM might house critical data that needs persistent uptime and shouldn't be deleted)

### Explain how you would figure out the correct format for creating a VM with the “CentOS stream 10” image (the specific image is up to you).

In order to create a VM with CentOS Stream 10 the image project and interfaces and the size need to be specified as initialize params within the boot disk configuration of the compute engine.
  
```
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-10"
      size  = 100
    }
  }
```

### Explain the difference between the “name” argument and the computed “id” and “self_link” attributes

The name how the compute resourse is named in GCP.

The compute.id is the unique attribute assigned to the resource by the cloud provider after it is created.

The self_link attribute is the URI of a resource.

---