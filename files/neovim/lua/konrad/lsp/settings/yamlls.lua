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
            format = {
                enable = false -- use prettier from null-ls instead
            },
            schemas = vim.list_extend(
                {
                    {
                        description = 'Newest kubernetes scheima from yannh',
                        fileMatch = { '/k8s/**' },
                        name = 'kubernetes',
                        url = 'https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json',
                    }
                },
                schemastore.yaml.schemas()
            ),
        },
    }
}
