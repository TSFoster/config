if vim.b.did_ftplugin_user then
  return true
end

local function dirvish_dir()
  return vim.b.dirvish and vim.b.dirvish._dir or vim.fn.expand("%:p")
end

local function current_path()
  local path = vim.fn.getline(".")
  if path == "" then
    return nil
  end

  if vim.fn.fnamemodify(path, ":p") == path then
    return path
  end

  return vim.fs.joinpath(dirvish_dir(), path)
end

local function target_paths()
  local args = vim.fn.argv()
  if #args > 0 then
    return args
  end

  local path = current_path()
  return path and { path } or {}
end

local function visual_target_paths()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local paths = {}
  for _, path in ipairs(vim.fn.getline(start_line, end_line)) do
    if path ~= "" then
      if vim.fn.fnamemodify(path, ":p") == path then
        table.insert(paths, path)
      else
        table.insert(paths, vim.fs.joinpath(dirvish_dir(), path))
      end
    end
  end

  return paths
end

local function refresh()
  vim.cmd.Dirvish()
end

local function resolve_destination(input)
  if vim.fn.fnamemodify(input, ":p") == input then
    return input
  end

  return vim.fs.joinpath(dirvish_dir(), input)
end

vim.keymap.set("n", "yo/", function()
  vim.wo.conceallevel = (vim.wo.conceallevel == 0 and 2 or 0)
end, { buffer = true, desc = "Cycle conceallevel" })
vim.keymap.set("n", "mf", function()
  vim.ui.input({ prompt = "New file: " }, function(input)
    if not input or input == "" then
      return
    end

    local path = vim.fs.joinpath(dirvish_dir(), input)
    local file = io.open(path, "a")
    if file then
      file:close()
    end
    refresh()
  end)
end, { buffer = true, desc = "Create file in current directory" })
vim.keymap.set("n", "md", function()
  vim.ui.input({ prompt = "New directory: " }, function(input)
    if not input or input == "" then
      return
    end

    vim.fn.mkdir(vim.fs.joinpath(dirvish_dir(), input), "p")
    refresh()
  end)
end, { buffer = true, desc = "Create directory in current directory" })
local function copy_paths(paths)
  if #paths == 0 then
    return
  end

  local prompt = #paths == 1 and ("Copy to: ")
    or ("Copy " .. #paths .. " selected entries to: ")

  vim.ui.input({ prompt = prompt }, function(input)
    if not input or input == "" then
      return
    end

    local destination = resolve_destination(input)
    local destination_is_dir = vim.fn.isdirectory(destination) == 1

    if #paths > 1 and not destination_is_dir then
      vim.notify("Destination must be an existing directory when copying multiple entries", vim.log.levels.ERROR)
      return
    end

    for _, path in ipairs(paths) do
      local target = destination_is_dir and vim.fs.joinpath(destination, vim.fs.basename(path)) or destination
      vim.fn.system({ "cp", "-R", path, target })
      if vim.v.shell_error ~= 0 then
        vim.notify("Failed to copy " .. vim.fs.basename(path), vim.log.levels.ERROR)
        return
      end
    end

    refresh()
  end)
end

local function delete_paths(paths)
  if #paths == 0 then
    return
  end

  local prompt = #paths == 1 and ("Delete " .. vim.fn.fnamemodify(paths[1], ":t") .. "? [y/N] ")
    or ("Delete " .. #paths .. " selected entries? [y/N] ")

  vim.ui.input({ prompt = prompt }, function(input)
    if input ~= "y" and input ~= "Y" then
      return
    end

    for _, path in ipairs(paths) do
      if vim.fn.isdirectory(path) == 1 then
        vim.fn.delete(path, "rf")
      else
        vim.fn.delete(path)
      end
    end

    if vim.fn.argc() > 0 then
      vim.cmd.arglocal()
      vim.cmd.argdelete({ args = { "*" }, mods = { silent = true, emsg_silent = true } })
    end

    refresh()
  end)
end

vim.keymap.set("n", "cp", function()
  copy_paths(target_paths())
end, { buffer = true, desc = "Copy current entry" })
vim.keymap.set("x", "cp", function()
  copy_paths(visual_target_paths())
end, { buffer = true, desc = "Copy selected entries" })
vim.keymap.set("n", "rm", function()
  delete_paths(target_paths())
end, { buffer = true, desc = "Delete current entry" })
vim.keymap.set("x", "rm", function()
  delete_paths(visual_target_paths())
end, { buffer = true, desc = "Delete selected entries" })

vim.g.dirvish_mode = ":sort ,^\v(.*[/])|\ze,"

vim.b.did_ftplugin_user = true
