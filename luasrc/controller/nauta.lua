module("luci.controller.nauta", package.seeall)

function index()
    entry({"admin", "services", "nauta"}, cbi("nauta"), _("Nauta"), 90)
end
