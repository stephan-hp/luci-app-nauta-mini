include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-nauta
PKG_VERSION:=1.0
PKG_RELEASE:=1

LUCI_TITLE:=Nauta ETECSA Login
LUCI_DESCRIPTION:=Login automático al portal cautivo de ETECSA
LUCI_DEPENDS:=+wget +curl +luci-base
LUCI_PKGARCH:=all

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
