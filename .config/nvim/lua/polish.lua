-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
-- lua/polish.lua

-- Keymap to toggle Copilot Chat
vim.keymap.set("n", "<A-i>", ":CopilotChatToggle<CR>", { noremap = true, silent = true })
