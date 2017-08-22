CLUSTER ?= demo
PLATFORM ?= aws
TMPDIR ?= /tmp
TOP_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BUILD_DIR = $(TOP_DIR)/build/$(CLUSTER)
INSTALLER_BIN = $(TOP_DIR)/installer/bin/$(shell uname | tr '[:upper:]' '[:lower:]')/installer
TF_DOCS := $(shell which terraform-docs 2> /dev/null)
TF_EXAMPLES := $(shell which terraform-examples 2> /dev/null)
TF_RC := $(TOP_DIR)/.terraformrc
TF_CMD = TERRAFORM_CONFIG=$(TF_RC) terraform
TF_STATE_PREFIX = tectonic
AZURE_STORAGE_KEY := $(shell az storage account keys list -n $(AZURE_STORAGE_ACCOUNT) -g $(STORAGE_ACCOUNT_RG) | jq '.[0].value')

$(info Using build directory [${BUILD_DIR}])

.PHONY: all
all: apply

$(INSTALLER_BIN):
	$(MAKE) build -C $(TOP_DIR)/installer

installer-env: $(INSTALLER_BIN) terraformrc.example
	sed "s|<PATH_TO_INSTALLER>|$(INSTALLER_BIN)|g" terraformrc.example > $(TF_RC)

.PHONY: localconfig
localconfig:
	mkdir -p $(BUILD_DIR)
	cp examples/*$(subst /,-,$(PLATFORM)) $(BUILD_DIR)/terraform.tfvars

.PHONY: terraform-init
terraform-init: installer-env
ifneq ($(shell $(TF_CMD) version | grep -E "Terraform v0\.1[0-9]\.[0-9]+"), )
	cd $(BUILD_DIR) && $(TF_CMD) init -backend-config="storage_account_name=$(AZURE_STORAGE_ACCOUNT)" -backend-config="key=$(TF_STATE_PREFIX)-$(CLUSTER).tfstate" -backend-config="access_key=$(AZURE_STORAGE_KEY)" -get=false -reconfigure $(TOP_DIR)/platforms/$(PLATFORM)
endif

.PHONY: terraform-get
terraform-get: terraform-init
	cd $(BUILD_DIR) && $(TF_CMD) get $(TF_GET_OPTIONS) $(TOP_DIR)/platforms/$(PLATFORM)

.PHONY: plan
plan: installer-env terraform-get
	cd $(BUILD_DIR) && $(TF_CMD) plan $(TF_PLAN_OPTIONS) $(TOP_DIR)/platforms/$(PLATFORM)

.PHONY: apply
apply: installer-env terraform-get
	cd $(BUILD_DIR) && $(TF_CMD) apply $(TF_APPLY_OPTIONS) $(TOP_DIR)/platforms/$(PLATFORM)

.PHONY: destroy
destroy: installer-env terraform-get
	cd $(BUILD_DIR) && $(TF_CMD) destroy $(TF_DESTROY_OPTIONS) -force $(TOP_DIR)/platforms/$(PLATFORM)

.PHONY: payload
payload:
	@${TOP_DIR}/modules/update-payload/make-update-payload.sh > /dev/null

define terraform-docs
	$(if $(TF_DOCS),,$(error "terraform-docs revision >= a8b59f8 is required (https://github.com/segmentio/terraform-docs)"))

	@echo '<!-- DO NOT EDIT. THIS FILE IS GENERATED BY THE MAKEFILE. -->' > $1
	@echo '# Terraform variables' >> $1
	@echo $2 >> $1
	terraform-docs --no-required markdown $3 $4 $5 $6 >> $1
endef

define terraform-examples
	$(if $(TF_EXAMPLES),,$(error "terraform-examples revision >= 83d7ad6 is required (https://github.com/s-urbaniak/terraform-examples)"))
	terraform-examples $2 $3 $4 $5 > $1
endef

.PHONY: docs
docs:
	$(call terraform-docs, Documentation/variables/config.md, \
			'This document gives an overview of variables used in all platforms of the Tectonic SDK.', \
			config.tf)

	$(call terraform-docs, Documentation/variables/aws.md, \
			'This document gives an overview of variables used in the AWS platform of the Tectonic SDK.', \
			platforms/aws/variables.tf)

	$(call terraform-docs, Documentation/variables/azure.md, \
			'This document gives an overview of variables used in the Azure platform of the Tectonic SDK.', \
			platforms/azure/variables.tf)

	$(call terraform-docs, Documentation/variables/openstack-neutron.md, \
			'This document gives an overview of variables used in the Openstack/Neutron platform of the Tectonic SDK.', \
			platforms/openstack/neutron/variables.tf)

	$(call terraform-docs, Documentation/variables/metal.md, \
			'This document gives an overview of variables used in the bare metal platform of the Tectonic SDK.', \
			platforms/metal/variables.tf)

	$(call terraform-docs, Documentation/variables/vmware.md, \
			'This document gives an overview of variables used in the VMware platform of the Tectonic SDK.', \
			platforms/vmware/variables.tf)

.PHONY: examples
examples:
	$(call terraform-examples, examples/terraform.tfvars.aws, \
			config.tf, \
			platforms/aws/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.azure, \
			config.tf, \
			platforms/azure/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.openstack-neutron, \
			config.tf, \
			platforms/openstack/neutron/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.metal, \
			config.tf, \
			platforms/metal/variables.tf)

	$(call terraform-examples, \
			examples/terraform.tfvars.vmware, \
			config.tf, \
			platforms/vmware/variables.tf)

.PHONY: clean
clean: destroy
	rm -rf $(BUILD_DIR)
	$(MAKE) clean -C $(TOP_DIR)/installer
	rm -f $(TF_RC)

# This target is used by the GitHub PR checker to validate canonical syntax on all files.
#
.PHONY: structure-check
structure-check:
	$(eval FMT_ERR := $(shell terraform fmt -list -write=false .))
	@if [ "$(FMT_ERR)" != "" ]; then echo "misformatted files (run 'terraform fmt .' to fix):" $(FMT_ERR); exit 1; fi

	@if $(MAKE) docs && ! git diff --exit-code; then echo "outdated docs (run 'make docs' to fix)"; exit 1; fi
	@if $(MAKE) examples && ! git diff --exit-code; then echo "outdated examples (run 'make examples' to fix)"; exit 1; fi
	@if $(TOP_DIR)/modules/update-payload/make-update-payload.sh && ! git diff --exit-code; then echo "outdated payload (run '$(TOP_DIR)/modules/update-payload/make-update-payload.sh' to fix)"; exit 1; fi

SMOKE_SOURCES := $(shell find $(TOP_DIR)/tests/smoke -name '*.go')
.PHONY: bin/smoke
bin/smoke: $(SMOKE_SOURCES)
	@CGO_ENABLED=0 go test ./tests/smoke/ -c -o bin/smoke

.PHONY: vendor-smoke
vendor-smoke: $(TOP_DIR)/tests/smoke/glide.yaml
	@cd $(TOP_DIR)/tests/smoke && glide up -v
	@cd $(TOP_DIR)/tests/smoke && glide-vc --use-lock-file --no-tests --only-code
