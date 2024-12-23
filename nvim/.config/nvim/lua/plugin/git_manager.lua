if YcVim.env.git == "neogit" then
  return { require "plugin.neogit", require "plugin.gitblame" }
end

return require "plugin.fugitive"
