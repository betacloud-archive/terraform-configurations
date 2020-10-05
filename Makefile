CONFIGURATION = docker
ENVIRONMENT = betacloud
NAME = $(CONFIGURATION)
USERNAME = ubuntu

OPENSTACK = openstack

IDENTIFIER = $(CONFIGURATION).$(NAME).$(ENVIRONMENT)
RESOURCE = module.docker.openstack_networking_floatingip_v2.floatingip_management

NEED_OSCLOUD := $(shell test -z "$$OS_PASSWORD" -a -z "$$OS_CLOUD" && echo 1 || echo 0)
ifeq ($(NEED_OSCLOUD),1)
  export OS_CLOUD=$(ENVIRONMENT)
endif

.management_address.$(IDENTIFIER):
	@MANAGEMENT_ADDRESS=$$(terraform output management_address); \
	echo "MANAGEMENT_ADDRESS=$$MANAGEMENT_ADDRESS" > $@;

.id_rsa.$(IDENTIFIER):
	@PRIVATE_KEY=$$(terraform output management_key); \
	echo "$$PRIVATE_KEY" > $@; \
	chmod 0600 $@

attach: init
	@terraform import -config $(CONFIGURATION) -var-file="environments/environment-$(ENVIRONMENT).tfvars" $(RESOURCE) $(PARAMS)

detach: init
	@terraform state rm $(RESOURCE) $(PARAMS)

init:
	@if [ ! -d .terraform/plugins ]; then \
	  terraform init $(CONFIGURATION); \
	fi

	@if [ -d "terraform.tfstate.d/$(IDENTIFIER)" ]; then \
	  terraform workspace select $(IDENTIFIER); \
	else \
	  terraform workspace new $(IDENTIFIER); \
	fi

clean: init
	@terraform destroy -auto-approve -var-file="environments/environment-$(ENVIRONMENT).tfvars" $(PARAMS) $(CONFIGURATION)
	@rm -f .management_address.$(IDENTIFIER)
	@rm -f .id_rsa.$(IDENTIFIER)
	@terraform workspace select default
	@terraform workspace delete $(IDENTIFIER)

create: init
	@terraform apply -auto-approve -var-file="environments/environment-$(ENVIRONMENT).tfvars" -var="name=$(NAME)" -var="environment=$(ENVIRONMENT)" $(PARAMS) $(CONFIGURATION)

log: .management_address.$(IDENTIFIER)
	@$(OPENSTACK) console log show $(NAME)

login: .management_address.$(IDENTIFIER) .id_rsa.$(IDENTIFIER)
	@source ./.management_address.$(IDENTIFIER); \
	ssh -i .id_rsa.$(IDENTIFIER) $(USERNAME)@$$MANAGEMENT_ADDRESS

openstack: init
	@$(OPENSTACK)

sync: .management_address.$(IDENTIFIER) .id_rsa.$(IDENTIFIER)
	@source ./.management_address.$(IDENTIFIER); \
	rsync -av --delete -e "ssh -i .id_rsa.$(IDENTIFIER)" $(CONFIGURATION)/service/ $(USERNAME)@$$MANAGEMENT_ADDRESS:/home/$(USERNAME)/service/

bootstrap: .management_address.$(IDENTIFIER) .id_rsa.$(IDENTIFIER)
	@source ./.management_address.$(IDENTIFIER); \
	ssh -i .id_rsa.$(IDENTIFIER) $(USERNAME)@$$MANAGEMENT_ADDRESS "bash /home/$(USERNAME)/service/bootstrap.sh"

watch: .management_address.$(IDENTIFIER) .id_rsa.$(IDENTIFIER)
	@source ./.management_address.$(IDENTIFIER); \
	DISP=0; \
	if test "$$COLORTERM" = "1"; then \
	  GREEN=$$(echo -e "\e[0;32m"); GREENBOLD=$$(echo -e "\e[1;32m"); BOLD=$$(echo -e "\e[0;1m"); RED=$$(echo -e "\e[0;31m"); YELLOW=$$(echo -e "\e[0;33m"); NORM=$$(echo -e "\e[0;0m"); \
	fi; \
	while true; do \
	  LEN=$$(ssh -o StrictHostKeyChecking=no -i .id_rsa.$(IDENTIFIER) $(USERNAME)@$$MANAGEMENT_ADDRESS sudo wc -l /var/log/cloud-init-output.log 2>/dev/null); \
	  LEN=$${LEN%% *}; \
	  if test -n "$$LEN" -a "$$LEN" != "$$DISP"; then \
	    OUT=$$(ssh -o StrictHostKeyChecking=no -i .id_rsa.$(IDENTIFIER) $(USERNAME)@$$MANAGEMENT_ADDRESS sudo tail -n $$((LEN-DISP)) /var/log/cloud-init-output.log 2>/dev/null); \
	    echo -e "$$OUT" | sed -e "s/^\(TASK.*\)$$/$$BOLD\1$$NORM/" -e "s/^\(PLAY.*\)$$/$$GREEN\1$$NORM/" -e "s/^\(The system is finally up.*\)$$/$$GREENBOLD\1$$NORM/" -e "s/\(FAILED\)/$$RED\1$$NORM/g" -e "s/\(failed=[1-9][0-9]*\|unreachable=[1-9][0-9]*\)/$$RED\1$$NORM/g" -e "s/\(warn\|WARN\|RETRYING\)/$$YELLOW\1$$NORM/" -e "s/\(ok:\|ok=[0-9]*\)/$$GREEN\1$$NORM/"; \
	    if echo "$$OUT" | grep '^The system is finally up' >/dev/null 2>&1; then break; fi; \
	    DISP=$$LEN; \
	    sleep 5; \
	  fi; \
	done;

PHONY: attach bootstrap clean create detach log login openstack sync watch
