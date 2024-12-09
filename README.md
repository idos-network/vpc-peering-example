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
    ```bash
    ssh-keygen -f id_example
    ```

4. Apply this config by running
    ```bash
    terraform init
    terraform apply
    ```

4. Tell idOS what's your `vpc_peering_connection_id`

    You can consult it with `terraform output -raw vpc_peering_connection_id ; echo`

5. Configure the VM to run the node
   1. Connect to the VM
       ```bash
       ssh -i id_example ec2-user@`terraform output -raw instance_public_ip`
       ```
   2. Install docker and log out

       If you don't log out after running `usermod`, the addition to the `docker` group won't be picked up.
       ```bash
       sudo dnf install -y docker
       sudo usermod -a -G docker ec2-user
       sudo systemctl enable --now docker.service
       exit
       ```
   3. Copy over the `genesis.json` file
       ```bash
       ssh -i id_example ec2-user@`terraform output -raw instance_public_ip` mkdir -p kwil-home-dir
       scp -i id_example genesis.json ec2-user@`terraform output -raw instance_public_ip`:kwil-home-dir/
       ```
   3. Connect to the VM again
       Note that we'll be using ssh agent forwarding (`-A`) to facilitate authentication with GitHub.
       ```bash
       ssh -A -i id_example ec2-user@`terraform output -raw instance_public_ip`
       ```
   4. Do the rest of the ambient setup
       ```bash
       sudo dnf install -y git git-lfs vim
       sudo curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
       sudo chmod 755 /usr/local/bin/docker-compose
       ssh-keyscan github.com >> .ssh/known_hosts
       ```
   5. Clone `idos-kgw`
       ```bash
       git clone git@github.com:idos-network/idos-kgw.git
       cd idos-kgw
       git lfs pull
       ```
   6. Create initial configuration
       ```bash
       docker network create kwil-dev
       sed -i 's/^ARCH=arm64/ARCH=amd64/' .env
       docker-compose -f compose.peer.yaml run --rm node /app/bin/kwil-admin setup peer --root-dir /app/home_dir/ --genesis /app/home_dir/genesis.json

       ```
   7. Copy `config.toml` into `kwil-home-dir` folder (overwrite existent the file in this folder)
   8. Run the peer node
        ```bash
        docker-compose -f compose.peer.yaml up -d
        ```

   9. Request the network to became a validator
       ```bash
       docker-compose run --rm node /app/bin/kwil-admin validators join --rpcserver /sockets/node.admin-sock
       ```
       Ask idOS to approve your request to join as a validator.
       Wait until majority nodes of the network vote on this request.
   10. To get an information about node and it's status
       ```bash
       docker-compose -f compose.peer.yaml run --rm -T node /app/bin/kwil-admin node status --rpcserver /sockets/node.admin-sock | jq -r .node.node_id
       ```
    11. To see if the node is in validator's list
        ```bash
        docker-compose run --rm node /app/bin/kwil-admin validators list --rpcserver /sockets/node.admin-sock
        ```
   12. Get back
       ```bash
       exit
       ```

6. Provide the `instance_private_ip` output to idOS to be included in the load balancer.
