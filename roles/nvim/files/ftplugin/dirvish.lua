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

local function refresh()
  vim.cmd("Dirvish")
end

vim.keymap.set(
  "n", "yo/",
  function()
    vim.wo.conceallevel = (vim.wo.conceallevel == 0 and 2 or 0)
  end,
  { buffer = true, desc = "Cycle conceallevel" }
)
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
vim.keymap.set("n", "rm", function()
  local paths = target_paths()
  if #paths == 0 then
    return
  end

  local prompt = #paths == 1
      and ("Delete " .. vim.fn.fnamemodify(paths[1], ":t") .. "? [y/N] ")
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
      vim.cmd("arglocal")
      vim.cmd("silent! argdelete *")
    end

    refresh()
  end)
end, { buffer = true, desc = "Delete current entry" })

vim.b.did_ftplugin_user = true
