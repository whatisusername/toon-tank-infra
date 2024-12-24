# Detect the operating system
ifeq ($(OS), Windows_NT)
	OS_NAME := Windows
else
	OS_NAME := $(shell uname -s)
endif

# Include the appropriate Makefile based on the OS
ifeq ($(OS_NAME), Windows)
	SHELL := cmd
else ifeq ($(OS_NAME), Darwin)
	SHELL := /bin/bash
else ifeq ($(OS_NAME), Linux)
	SHELL := /bin/bash
else
	$(error Unsupported OS: $(OS_NAME))
endif

# Define paths
LIVE_PATH := terraform/live
MODULE_PATH := terraform/modules
TEMPLATE_PATH := terraform/templates

# Targets
.PHONY: create_tf_comp create_tf_module create_tf_sub_module create_tf_template

create_tf_comp:
ifeq ($(OS_NAME), Windows)
	@if not exist "$(LIVE_PATH)\$(LIVE)\$(NAME)" ( \
		mkdir "$(LIVE_PATH)\$(LIVE)\$(NAME)" && \
		powershell -Command "cd '$(LIVE_PATH)\$(LIVE)\$(NAME)'; New-Item -Path versions.tf,providers.tf,main.tf,variables.tf,outputs.tf,variables.auto.tfvars -ItemType File" \
	)
else
	@if [[ ! -d "$(LIVE_PATH)/$(LIVE)/$(NAME)" ]]; then \
		mkdir -p "$(LIVE_PATH)/$(LIVE)/$(NAME)"; \
	fi
	@files=("versions.tf" "providers.tf" "main.tf" "variables.tf" "outputs.tf" "variables.auto.tfvars"); \
	for file in $${files[@]}; do \
		touch "$(LIVE_PATH)/$(LIVE)/$(NAME)/$${file}"; \
	done
endif

create_tf_module:
ifeq ($(OS_NAME), Windows)
	@if not exist "$(MODULE_PATH)\$(NAME)" ( \
		mkdir "$(MODULE_PATH)\$(NAME)" && \
		powershell -Command "cd '$(MODULE_PATH)\$(NAME)'; New-Item -Path versions.tf,main.tf,variables.tf,outputs.tf,README.md -ItemType File" \
	)
else
	@if [[ ! -d "$(MODULE_PATH)/$(NAME)" ]]; then \
		mkdir -p "$(MODULE_PATH)/$(NAME)"; \
	fi
	@files=("versions.tf" "main.tf" "variables.tf" "outputs.tf" "README.md"); \
	for file in $${files[@]}; do \
		touch "$(MODULE_PATH)/$(NAME)/$${file}"; \
	done
endif

create_tf_sub_module:
ifeq ($(OS_NAME), Windows)
	@if not exist "$(MODULE_PATH)\$(MAIN)\modules\$(NAME)" ( \
		mkdir "$(MODULE_PATH)\$(MAIN)\modules\$(NAME)" && \
		powershell -Command "cd '$(MODULE_PATH)\$(MAIN)\modules\$(NAME)'; New-Item -Path versions.tf,main.tf,variables.tf,outputs.tf,README.md -ItemType File" \
	)
else
	@if [[ ! -d "$(MODULE_PATH)/$(MAIN)/modules/$(NAME)" ]]; then \
		mkdir -p "$(MODULE_PATH)/$(MAIN)/modules/$(NAME)"; \
	fi
	@files=("versions.tf" "main.tf" "variables.tf" "outputs.tf" "README.md"); \
	for file in $${files[@]}; do \
		touch "$(MODULE_PATH)/$(MAIN)/modules/$(NAME)/$${file}"; \
	done
endif

create_tf_template:
ifeq ($(OS_NAME), Windows)
	@if not exist "$(TEMPLATE_PATH)" ( \
		mkdir "$(TEMPLATE_PATH)" \
	)
	@echo.> "$(TEMPLATE_PATH)\$(NAME).tftpl"
else
	@if [[ ! -d "$(TEMPLATE_PATH)" ]]; then \
		mkdir -p "$(TEMPLATE_PATH)"; \
	fi
	@touch "$(TEMPLATE_PATH)/$(NAME).tftpl"
endif
