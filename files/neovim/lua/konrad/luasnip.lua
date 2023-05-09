local ls = require("luasnip")
local snip = ls.snippet
local text = ls.text_node

ls.add_snippets("yaml", {
    snip({
        trig = "yaml-modeline",
        name = "yamlls modeline template",
        dscr = "yaml-language-server modeline template with kubernetes schema by default",
    }, {
        text("# yaml-language-server: $schema=https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json")
    }),
})

ls.add_snippets("all", {
    snip({
        trig = "shrug",
        name = "ascii shrug",
        dscr = "shrug when you have nothing better to say",
    }, {
        text("¯\\_(ツ)_/¯")
    }),
    snip({
        trig = "rageflip",
        name = "ascii rageflip",
        dscr = "rageflip when you have enough",
    }, {
        text("(╯°□°)╯彡┻━┻")
    }),
})
