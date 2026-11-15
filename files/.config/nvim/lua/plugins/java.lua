-- Stable Homebrew symlink, so a `brew upgrade openjdk@21` keeps it valid.
local jdk = "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"

-- java.vim embeds markdown syntax for Java 23 `///` doc comments.
-- gabrielelana/vim-markdown lacks the groups it links, raising E28.
vim.g.java_ignore_markdown = 1

local eclipse_init = vim.fn.stdpath("config") .. "/gradle/eclipse-init.gradle"

local function mtime(path)
  local stat = vim.uv.fs_stat(path)
  return stat and stat.mtime.sec
end

-- Each Gradle project with Java sources needs a `.classpath` newer than every
-- build file. A jdtls Gradle sync rewrites `.classpath` to point at Buildship,
-- which a static import cannot read, so treat that as stale too.
local function eclipse_files_stale(root)
  local build_files = {}
  for _, pattern in ipairs({ "/*.gradle", "/*/*.gradle", "/*/*/*.gradle" }) do
    vim.list_extend(build_files, vim.fn.glob(root .. pattern, false, true))
  end
  local newest = 0
  for _, file in ipairs(build_files) do
    newest = math.max(newest, mtime(file) or 0)
  end
  for _, file in ipairs(build_files) do
    local dir = vim.fs.dirname(file)
    if vim.fn.isdirectory(dir .. "/src/main/java") == 1 then
      local classpath = dir .. "/.classpath"
      local f = io.open(classpath)
      if not f then
        return true
      end
      local buildship = f:read("*a"):find("buildship", 1, true)
      f:close()
      if buildship or (mtime(classpath) or 0) < newest then
        return true
      end
    end
  end
  return false
end

-- Blocks for about 2s with a warm Gradle daemon, only when files are stale.
local function regenerate_eclipse_files(root)
  vim.notify("Generating Eclipse project files for jdtls")
  local result = vim
    .system({ "./gradlew", "-q", "--init-script", eclipse_init, "cleanEclipse", "eclipse" }, {
      cwd = root,
      env = { JAVA_HOME = jdk },
    })
    :wait(180000)
  if result.code ~= 0 then
    vim.notify("gradlew eclipse failed:\n" .. (result.stderr or ""), vim.log.levels.ERROR)
  end
end

return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      -- VS Code's jdtls JVM flags: ParallelGC with these ratios returns idle heap
      -- to the OS. Measured on PVS: 820MB resident instead of 1.25GB.
      -- -Xms100m overrides the -Xms1G that Mason's launcher passes first.
      vim.list_extend(opts.cmd, {
        "--jvm-arg=-XX:+UseParallelGC",
        "--jvm-arg=-XX:GCTimeRatio=4",
        "--jvm-arg=-XX:AdaptiveSizePolicyWeight=90",
        "--jvm-arg=-Dsun.zip.disableMemoryMapping=true",
        "--jvm-arg=-Xms100m",
        "--jvm-arg=-Xmx2G",
      })
      -- A workspace once imported through Gradle must not be reused for static
      -- Eclipse imports, so these get their own directory.
      opts.jdtls_workspace_dir = function(project_name)
        return vim.fn.stdpath("cache") .. "/jdtls-eclipse/" .. project_name .. "/workspace"
      end
      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          configuration = {
            runtimes = { { name = "JavaSE-21", path = jdk, default = true } },
          },
          -- jdtls re-syncs every Gradle project on start, about 20s on PVS.
          -- Static Eclipse files from `gradlew eclipse` load in about 3s.
          import = { gradle = { enabled = false }, maven = { enabled = false } },
          -- No whole-workspace compile. Open files still get errors as you type.
          -- Measured on PVS: 860-910MB steady versus 850-1150MB with it on.
          autobuild = { enabled = false },
        },
      })
      -- Called by LazyVim on every Java FileType, before start_or_attach.
      opts.jdtls = function(config)
        if not (vim.g.lsp_on and config.root_dir) then
          return config
        end
        if vim.fn.filereadable(config.root_dir .. "/gradlew") == 1
          and eclipse_files_stale(config.root_dir) then
          regenerate_eclipse_files(config.root_dir)
        end
        -- jdtls reads import settings only at initialize.
        -- nvim-jdtls never copies `settings` into `init_options`.
        config.init_options = config.init_options or {}
        config.init_options.settings = config.settings
        return config
      end
      -- The repo has no Java formatter, so jdtls's Eclipse style on save
      -- would reformat whole files. Format a selection with <leader>cf.
      opts.on_attach = function(args)
        vim.b[args.buf].autoformat = false
        local function gradle_test(whole_module)
          local file = vim.api.nvim_buf_get_name(args.buf)
          local root = vim.fs.root(file, "gradlew")
          local module = file:match("/modules/([^/]+)/")
          if not (root and module) then
            return vim.notify("Not in a Gradle module", vim.log.levels.WARN)
          end
          local cmd = { "./gradlew", ":modules:" .. module .. ":test" }
          if not whole_module and file:find("/src/test/") then
            vim.list_extend(cmd, { "--tests", vim.fn.fnamemodify(file, ":t:r") })
          end
          Snacks.terminal(cmd, { cwd = root, auto_close = false })
        end
        local map = function(lhs, fn, desc)
          vim.keymap.set("n", lhs, fn, { buffer = args.buf, desc = desc })
        end
        map("<leader>tt", function() gradle_test(false) end, "Gradle Test Class")
        map("<leader>tm", function() gradle_test(true) end, "Gradle Test Module")
      end
    end,
  },
}
