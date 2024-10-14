# Terraform Project for oiai

# Used Tools 

1. Cloud Provider : Azure
2. Network Design : Hub & Spoke Network Architecture 
3. Kubernetes     : Azure Kubernetes Service with Security Baseline
4. CI/CD          : Azure DevOps with self-hosted runners
5. Templates      : Helm Templates
6. SDLC           : Gitlow Release branching strategy


## Project Structure

``` bash
.
├── openai-infra-code 
    |-- hub_spoke_network    # Provision Hub V.net and Spoke V.net includes respective subnets, route tables, Azure Firewall with Network and Application Rules , UAMI's for AKS, Log analytics workspace
│   ├── azure_kubernetes_aks # Provision AKS with Security Baseline includes key vault, dedicated node pools include post deployment configurations
│   ├── modules              # Terraform Azure Modules for provisioning respective resources.

├── openai-web,api,db        # hold respective frontend, Api and db code including CI/CD deployment pipelines
│   ├── helm/                # Holds respective environment helm values for each application deployment
│   ├── pipelines/           # Holds respective CI/CD pipelines including build and deployment steps  

└── pipeline-templates       # Holds DevOps central templates for steps to build, scan and deployment to target AKS cluster.
│   ├── helm/                # Holds Respective application helm charts.
│   ├── templates/           # Holds respective CI/CD central template pipeline including build and deployment steps  

```
## Decisions

Azure Networking : Hub and Spoke Networks
- Hub Network :
   - AzureFirewallSubnet -- Holds Azure Firewall Resources to control outbound traffic from spoke networks and it gives visibility of outbound traffic from all networks.
   - GatewaySubnet -- Holds VPN Gateway for VPN, on-prem connectivity
   - BastionSubent -- Holds Bastion Host for connecting spoke network jump servers
   - ApplicationGatewaySubnet -- Holds Application gateway Resource for external connectivity using Layer 7 load balancing and routes the traffic to backend applications includes AKS Ingress controllers.
   - ADOAgentSubnets -- Holds Azure DevOps linux and windows agents VMSS scale sets, these VMSS agents will configure as Azure DevOps self-hosted agents/runners
   - Private Hosted Zones -- Holds respective resource private hosted zone and hub and spoke network will link to each hosted zone for Private DNS Resolution
- Spoke Network :
   - APP/AKS Subnet : Dedicated subnet for provisioning AKS Cluster
   - Ingress Subnet : Dedicated Subnet for Ingress Controller Internal Private Load Balancer  
   - PE Subnet      : Dedicated Private Endpoints for AKS Cluster to connect Azure Resource using private network including Key Valut, ACR, other Azure Services
   - Managed Identity : Provisions Dedicated UAMI for AKS Control Plane and Nodes with least privileges, Disk encryption sets UAMI for encryption.

Azure Kubernetes Service :
   - will provision AKS with dedicated system node pools, on demand and spot node pools and enabled Azure RBAC with AD Integration, Key Vault Secrets CSI Drivers for Key Vault Secret Integration, Defender enabled for runtime scanning.
   - post deployment configuration will provision cluster level components including Ingress controller, ELK for log monitoring, Prometheus stack for monitoring, Kyverno for OPA policy management etc.
   - Application specific environment secrets will be handled through azure key vault.

Azure DevOps :
   - Holds Code Repos, performs Continuous Integration and Deployment operations to deploy applications into respective target environments i.e AKS
   - requires respective ADO service connection to authenticate with Azure Kubernetes Cluster to deploy application . ( will use Azure Manger 
   Federated OpenId Service connection)
   - provision organization level agent pools (Azure Virtual Machine scale set)

SDLC : 
   - Development branch code will deploy into Development environments once the developers merge the features from feature branch.
   - Release branch (version: R1) code will be deployed to test environment once development testing completes
   - once the QA Testing completes the TEST image will be promoted to UAT and then PROD environments.
   - hot fix branch will handle any hotfix , will be deployed to PROD and then the code will merged to respective release and development branches.

   Improvements:
     - we can extend the CI pipeline to SCAN source code for SCA, SAST, Secret scanning steps, Image scanning once build completes
     - we can extend the CD pipeline to include smoke/basic sanity steps to confirm the application deployment successfully or not.


## Enhancements / Improvements

1. Centralized Log Monitoring -- Either ELK / Grafana Loki to handle all applications logs,
2. Centralized Cluster Monitoring -- Prometheus with Thanos and Grafana.
3. Centralized Secrets Management using HashiCorp Vault
4. Cost-Optimization: using automation we can start/stop the clusters outside business hours.
