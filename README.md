# terraform-configurations

Simple framework based on Terraform, Ansible and Docker Compose to manage standalone
services on an OpenStack cloud, independent of Kubernetes.

**Intended for development. Think twice before use in production.**

## Services

* CoreDNS
* Docker
* Keycloak
* MinIO
* Traefik

## Usage

* Get the IDs of all existing floating IP addresses in an environment
  (if no existing floating IP address should be used skip this step)

  ```
  make ENVIRONMENT=betacloud CONFIGURATION=base NAME=testing openstack
  (openstack) floating ip list
  ```

* Assign an existing floating IP address to a new service (if no existing
  floating IP address should be used skip this step)

  ```
  make ENVIRONMENT=betacloud CONFIGURATION=base NAME=testing attach PARAMS=a417a4a2-dc79-4d03-b037-986049962d33
  ```

* Create a new ``base`` service with the name ``testing``

  ```
  make ENVIRONMENT=betacloud CONFIGURATION=base NAME=testing create
  ```

* Watch the process of the service creation

  ```
  make ENVIRONMENT=betacloud CONFIGURATION=base NAME=testing watch
  ```

* Show the console log of the created service

  ```
  make ENVIRONMENT=betacloud CONFIGURATION=base NAME=testing log
  ```

* Open a new SSH session

  ```
  make ENVIRONMENT=betacloud CONFIGURATION=base NAME=testing login
  ```

* Sync the configuration directory with the deployed service

  ```
  make ENVIRONMENT=betacloud CONFIGURATION=base NAME=testing sync
  ```

* Re-run the bootstrap script

  ```
  make ENVIRONMENT=betacloud CONFIGURATION=base NAME=testing bootstrap
  ```

* Preserve the floating IP address (if the floating IP address should not
  be preserved skip this step)

  ```
  make ENVIRONMENT=betacloud CONFIGURATION=base NAME=testing detach
  ```

* Destroy the service

  ```
  make ENVIRONMENT=betacloud CONFIGURATION=base NAME=testing clean
  ```
