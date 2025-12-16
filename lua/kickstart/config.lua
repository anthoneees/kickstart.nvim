local M = {}

-- on_attach (moved from autocmd)
-- In this case, we create a function that lets us more easily define mappings specific
-- for LSP related items. It sets the mode, buffer and description for us each time.
M.on_attach = function(client, bufnr)
  local nmap = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  -- LSP provides Neovim with features like:
  --  - Go to definition
  --  - Find references
  --  - Autocompletion
  --  - Symbol Search
  --  - and more!
  --     -- Rename the variable under your cursor.
  --     --  Most Language Servers support renaming across files, etc.
  --     map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('grn', vim.lsp.buf.rename, '[R]e[n]ame')
  --     -- Execute a code action, usually your cursor needs to be on top of an error
  --     -- or a suggestion from your LSP for this to activate.
  --     map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
  nmap('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
  --     -- Find references for the word under your cursor.
  nmap('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  --     -- Jump to the implementation of the word under your cursor.
  --     --  Useful when your language has ways of declaring types without an actual implementation.
  nmap('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  --     -- Jump to the definition of the word under your cursor.
  --     --  This is where a variable was first declared, or where a function is defined, etc.
  --     --  To jump back, press <C-t>.
  nmap('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  --     -- WARN: This is not Goto Definition, this is Goto Declaration.
  --     --  For example, in C this would take you to the header.
  nmap('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  --     -- Fuzzy find all the symbols in your current document.
  --     --  Symbols are things like variables, functions, types, etc.
  nmap('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
  --     -- Fuzzy find all the symbols in your current workspace.
  --     --  Similar to document symbols, except searches over your entire project.
  nmap('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
  --     -- Jump to the type of the word under your cursor.
  --     --  Useful when you're not sure what type a variable is and you want to see
  --     --  the definition of its *type*, not where it was *defined*.
  nmap('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
  nmap('K', vim.lsp.buf.hover, 'Hover')

  -- The following two autocommands are used to highlight references of the
  -- word under your cursor when your cursor rests there for a little while.
  --    See `:help CursorHold` for information about when this is executed
  --
  -- When you move your cursor, the highlights will be cleared (the second autocommand).
  -- Reference highlighting
  -- Document Highlight
  if client.supports_method('textDocument/documentHighlight', { bufnr = bufnr }) then
    local group = vim.api.nvim_create_augroup('lsp-highlight-' .. bufnr, { clear = true })

    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = bufnr,
      group = group,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = bufnr,
      group = group,
      callback = vim.lsp.buf.clear_references,
    })
  end

  if client.supports_method 'textDocument/inlayHint' then
    nmap('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
    end, '[T]oggle Inlay [H]ints')
  end
end

-- capabilities
function M.capabilities()
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    return blink.get_lsp_capabilities()
  end
  return vim.lsp.protocol.make_client_capabilities()
end

M.servers = {
  lua_ls = {},
  gopls = {},
  ts_ls = {},
  eslint = {},
  html = {},
  cssls = {},
  hyprls = {},
}

M.filetype_to_server = {}
for server_name, _ in pairs(M.servers) do
  local ok, config = pcall(function()
    return require('lspconfig')[server_name].document_config.default_config
  end)

  if ok and config.filetypes then
    for _, ft in ipairs(config.filetypes) do
      M.filetype_to_server[ft] = server_name
    end
  end
end

return M
