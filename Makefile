
GO_SRC_URL:=https://github.com/golang/go/archive/go1.8.tar.gz
GO_SRC_TAR:=$(notdir $(GO_SRC_URL))
GO_BASE_NAME:=$(subst .tar.gz,,$(GO_SRC_TAR))

GO_PREFIX:=$(HOME)/local
GO_INSTALL_DIR:=$(HOME)/local/$(GO_BASE_NAME)
ENV_PATH:=$(findstring $(GO_INSTALL_DIR)/bin,$(PATH))
ENV_GOPATH:=$(findstring $(HOME)/go,$(GOPATH))

GO14_SRC_URL:=https://github.com/golang/go/archive/go1.4.3.tar.gz
GO14_SRC_TAR:=$(notdir $(GO14_SRC_URL))
GO14_SRC_DIR:=$(subst .tar.gz,,$(GO14_SRC_TAR))

TARGET = $(GO_INSTALL_DIR)/bin/go

env:
	@echo "target $(GO_INSTALL_DIR)/bin/go"
	@echo "       $(GO_SRC_URL)"
	@echo "$(if $(ENV_PATH),"ok. include PATH=$(ENV_PATH)","ng. not found PATH=$(GO_INSTALL_DIR)/bin")"
	@echo "$(if $(ENV_GOPATH),"ok. GOPATH=$(ENV_GOPATH)","ng. GOPATH=$(ENV_GOPATH)")"
	@echo "$(if $(shell ls $(TARGET) 2>/dev/null),"ok. exists $(TARGET)","ng. not found target. make build")"

build: $(TARGET)

$(TARGET): $(GO_SRC_TAR) $(GO14_SRC_DIR)/bin/go
	@echo "target $(GO_INSTALL_DIR)/bin/go"
	@echo "       $(GO_SRC_URL)"
	@echo "prerequisites $(GO_SRC_TAR)"
	rm -fr $(GO_INSTALL_DIR)
	mkdir $(GO_INSTALL_DIR)
	tar xzf $(GO_SRC_TAR) -C $(GO_INSTALL_DIR) --strip-components 1
	export GOROOT_BOOTSTRAP=$(PWD)/$(GO14_SRC_DIR) && cd $(GO_INSTALL_DIR)/src && ./make.bash

$(GO_SRC_TAR):
	wget -O $(GO_SRC_TAR) $(GO_SRC_URL)

$(GO14_SRC_DIR)/bin/go:
	rm -fr $(GO14_SRC_DIR)
	mkdir $(GO14_SRC_DIR)
	tar xzf $(GO14_SRC_TAR) -C $(GO14_SRC_DIR) --strip-components 1
	cd $(GO14_SRC_DIR)/src && ./make.bash

$(GO14_SRC_TAR):
	wget -O $(GO14_SRC_TAR) $(GO14_SRC_URL)

clean:
	rm -fr $(GO_INSTALL_DIR)

.PHONY: env build clean

