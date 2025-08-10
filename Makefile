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
	ln -rs vendor/pico/css/* static/css/


.PHONY: fmt
fmt:
	go fmt ./...
	npx prettier templates --write


.PHONY: run
run:
	go run main.go

# Clean the vendor directory
.PHONY: clean
clean:
	find static/css -type l -delete
	rm -rf $(VENDOR_DIR)
	@echo "Cleaned vendor directory"

