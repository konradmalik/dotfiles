-- https://github.com/redhat-developer/yaml-language-server
local schemastore_ok, schemastore = pcall(require, "schemastore")
if not schemastore_ok then
    vim.notify("cannot load schemastore")
    return
end

return {
    settings = {
        redhat = {
            telemetry = {
                enabled = false,
            },
        },
        yaml = {
            format  = {
                enable = false -- use prettier from null-ls instead
            },
            schemas = vim.list_extend(
                {
                    ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json"] =
                    { "k8s/**/*.yml", "k8s/**/*.yaml" },
                    -- or use:
                    -- # yaml-language-server: $schema=<urlToTheSchema>
                },
                schemastore.yaml.schemas()
            ),
        },
    }
}
