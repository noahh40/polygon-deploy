## Description
In this document we will describe how to deploy Polygon nodes onto Google Kubernetes Engine clusters
## Hardware requirements
Check minimum and recommended [hardware requirements](https://docs.polygon.technology/docs/validate/mainnet/validator-guide) in Polygon docs

### 3rd party components required
- Terragrun and terraform must be installed before
- Helmfile and helm must be installed before
- Also, to store some secrets in safe maner it's necessary to get [helm-secrets plugin installed](https://github.com/jkroepke/helm-secrets/wiki/Installation)

# Solution Deploy

## Step 1: Deploy infra via terragrunt
1. Check `project_id` parameters in all `terragrunt.hcl` files in `terragrunt` directory.
2. Network plan could be reused, in case you wish to have 3 or less PointsOfPresense (PoP)
3. In directory `terragrunt` run command `terrgrunt apply-all` and confirm the changes.

## Step 2: Deploy the Application via helmfile
### Pre-liminary steps
1. From step one you have created a couple GKE clusters up and running. It's time to connect to them by running the \
    command `gcloud container clusters get-credentials CLUSTER_NAME --region CLUSTER_REGION --project PROJECT_ID`
2. On step 1 the KMS keyring was created. KMS is encryption service and we have some secrets to encrypt.
    - In case you switched to a new project: please, check paths in `app/.sops.yaml`
    - In case you switched to a new project: fill files `app/environments/ENV_NAME/secrets/rabbit.yaml.dec` with new secrets (in clear text)
    - In case you switched to a new project: run `sops --encrypt app/environments/ENV_NAME/secrets/rabbit.yaml.dec > app/environments/ENV_NAME/secrets/rabbit.yaml`\
        for each Environment to encrypt your fresh secrets. Remove `rabbit.yaml.dec` files to prevent adding it into git.
    - In case you switched to a new project: retrive external IPs per each zone from `terragrunt` and put it into `helmfile`:
      1. in each dir `terragrunt/envs/ENV_NAME/ips` run `terragrunt output addresses` 
      2. get the IP and replace external IPs in `app/environments/ENV_NAME/helmfile.yaml`
      3. there is a separate IP for Global Load Balancer. To get it run terragrunt output addresses` in `terragrunt/envs/glb`
      4. put GLB address into `app/environments/eu/helmfile.yaml` as value for `global_ip: ` parameter in `mci` release
      5. also, put your `kubectl` context for appropriate cluster in `app/environments/ENV_NAME/helmfile.yaml` as value for `context:`
3. It's time to run deployment of our nodes. In `app/environments/` run `helmfile sync`. \
    In case you wish to deploy zone-by-zone you can execute helmfile in same ditectory with additional key like `helmfile -e eu sync`
