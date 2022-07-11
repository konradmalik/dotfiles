-- https://github.com/redhat-developer/yaml-language-server
return {
    settings = {
        redhat = {
            telemetry = {
                enabled = false,
            },
        },
        yaml = {
            format = {
                enable = false -- prettier
            },
            schemaStore = { enable = true },
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = { "/.github/workflows/*" },
                ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = { "/.gitlab-ci.yml",
                    "/ci/*", "/gitlabci-templates/*" },
                -- TODO kubernetes does not work :(
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json"] = { "/k8s/*" },
            },
        },
    },
}
