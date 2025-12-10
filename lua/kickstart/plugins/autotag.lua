return {
  'windwp/nvim-ts-autotag',
  event = 'InsertEnter',
  ft = {
    'html',
    'javascript',
    'typescript',
    'jsx',
    'tsx',
    'astro',
    'glimmer',
    'handlebars',
    'liquid',
    'markdown',
    'php',
    'rescript',
  },
  config = function()
    require('nvim-ts-autotag').setup {
      enable_close = true,
      enable_rename = true,
    }
  end,
}
