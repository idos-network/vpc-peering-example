# Example idOS node with VPC peering

This example is meant to be a bare-bones version of what's necessary to participate in an idOS network.

1. You'll need to ask the idOS association for a few values to use in the next steps:
    - Access to the `idos-kgw` repository
    - Terraform variables
      - `remote_account_id`
      - `remote_peer_region`
      - `remote_vpc_id`
      - `remote_cidr_block`
      - `cidr_block`
    - Node files
      - `config.toml`
      - `genesis.json`

2. Fill in this module's variables.
    > 💡 Tip
    >
    > Use a `terraform.tfvars` file for them to be picked up automatically

3. Generate a ssh keypair
    ```
    ssh-keygen -f id_example
    ```

4. Apply this config by running
    ```
    terraform init
    terraform apply
    ```

5. Configure the VM to run the node
   1. Connect to the VM
       ```
       ssh -i id_example ec2-user@`terraform output -json | jq -r .instance_public_ip.value`
       ```
   2. Install docker and log out

       If you don't log out after running `usermod`, the addition to the `docker` group won't be picked up.
       ```
       sudo dnf install -y docker
       sudo usermod -a -G docker ec2-user
       sudo systemctl enable --now docker.service
       exit
       ```
   3. Copy over the `genesis.json` file
       ```
       ssh -i id_example ec2-user@`terraform output -json | jq -r .instance_public_ip.value` mkdir -p kwil-home-dir
       scp -i id_example genesis.json ec2-user@`terraform output -json | jq -r .instance_public_ip.value`:kwil-home-dir/
       ```
   3. Connect to the VM again
       Note that we'll be using ssh agent forwarding (`-A`) to facilitate authentication with GitHub.
       ```
       ssh -A -i id_example ec2-user@`terraform output -json | jq -r .instance_public_ip.value`
       ```
   4. Do the rest of the ambient setup
       ```
       sudo dnf install -y git git-lfs vim
       sudo curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
       sudo chmod 755 /usr/local/bin/docker-compose
       ssh-keyscan github.com >> .ssh/known_hosts
       ```
   5. Clone `idos-kgw`
       ```
       git clone git@github.com:idos-network/idos-kgw.git
       cd idos-kgw
       git lfs pull
       ```
   6. Create initial configuration
       ```
       docker network create kwil-dev
       sed -i 's/^ARCH=arm64/ARCH=amd64/' .env
       docker-compose -f compose.peer.yaml run --rm node /app/bin/kwil-admin setup peer --root-dir /app/home_dir/ --genesis /app/home_dir/genesis.json
       docker-compose -f compose.peer.yaml up -d
       ```
   7. TODO Set `config.toml`
       ```
       ```
   7. TODO Ask the network to join as a validator
       ```
       ```
   8. Get the node's id
       ```
       docker-compose -f compose.peer.yaml run --rm -T node /app/bin/kwil-admin node status --rpcserver /sockets/node.admin-sock | jq -r .node.node_id
       ```
   8. Get back
       ```
       exit
       ```

6. Ask idOS to approve your request to join as a validator

99. Provide the `instance_private_ip` output to idOS to be included in the load balancer.
