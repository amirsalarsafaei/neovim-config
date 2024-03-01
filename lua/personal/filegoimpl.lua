local function create_files_for_interface(interface, receiver)
  -- Call goimpl and capture its output
  local goimpl_output = vim.fn.system(string.format('goimpl %s %s', receiver, interface))

  -- Split the output into lines
  local lines = vim.split(goimpl_output, '\n')

  -- Regex to match the method signatures
  local method_signature_pattern = '^func %[?(.+)%]? %[?(.-)%]?%((.*)%)'

  for _, line in ipairs(lines) do
    local match = line:match(method_signature_pattern)
    if match then
      local func_name = match:match('^%S+')

      -- Create a new file with the method implementation
      local file_name = string.format('%s.go', func_name)
      local file_content = line .. ' {\n\t// TODO: implement\n}\n'

      -- Write file_content to file_name
      local file = io.open(file_name, 'w')
      if file then
        file:write(file_content)
        file:close()
        print('Created file:', file_name)
      else
        print('Error creating file:', file_name)
      end
    end
  end
end

-- Add a Neovim command for creating the files
vim.api.nvim_create_user_command(
  'GoImplFiles',
  function(input)
    create_files_for_interface(input.args, input.fargs[1])
  end,
  {
    nargs = 2, -- We expect two arguments: the interface and the receiver
    complete = 'custom,v:lua.complete_go_interfaces', -- You may need a custom completion function for Go interfaces
  }
)
