local wezterm = require("wezterm")

local ssh_domains = {}
for host, sshconfig in pairs(wezterm.enumerate_ssh_hosts()) do
    if sshconfig.user ~= "git" then
        table.insert(ssh_domains, {
            name = host,
            remote_address = host,
            -- set to WezTerm once we install it on the remote hosts
            multiplexing = "None",
            assume_shell = "Posix",
        })
    end
end

return ssh_domains
