VENDOR_DIR := vendor
PICO_ZIP_URL := https://github.com/picocss/pico/archive/refs/heads/main.zip
PICO_ZIP_FILE := $(VENDOR_DIR)/pico.zip
PICO_EXTRACT_DIR := $(VENDOR_DIR)/pico

all: $(PICO_EXTRACT_DIR)

.PHONY: deps
deps: clean
	mkdir -p $(VENDOR_DIR)
	curl -L -o $(PICO_ZIP_FILE) $(PICO_ZIP_URL)
	unzip -q $(PICO_ZIP_FILE) -d $(VENDOR_DIR)
	mv $(VENDOR_DIR)/pico-main $(PICO_EXTRACT_DIR)
	rm $(PICO_ZIP_FILE)
	npm install -g prettier

.PHONY: fmt
fmt:
	go fmt ./...
	npx prettier templates --write


# Clean the vendor directory
.PHONY: clean
clean:
	rm -rf $(VENDOR_DIR)
	@echo "Cleaned vendor directory"

