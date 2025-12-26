include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-nauta-mini
PKG_VERSION:=1.0
PKG_RELEASE:=1

LUCI_TITLE:=Nauta Mini
LUCI_DEPENDS:=+luci-base +wget
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk
