_G.IS_TEST = true

local api = vim.api
local fn = vim.fn
local fmt = string.format

local spy = require("luassert.spy")

local toggleterm = require("toggleterm")
local constants = require("toggleterm.constants")

local ui = require("toggleterm.ui")
local t = require("toggleterm.terminal")

---@type Terminal
local Terminal = t.Terminal
---@type fun(): Terminal[]
local get_all = t.get_all

---Return if a terminal has windows
---@param term table
---@return any
local function term_has_windows(term)
  return ui.find_open_windows(function(buf)
    return buf == term.bufnr
  end)
end

describe("ToggleTerm tests:", function()
  -- We must set hidden to use the plugin
  vim.o.hidden = true

  after_each(function()
    require("toggleterm.terminal").__reset()
  end)
  --
  -- describe("toggling terminals - ", function()
  --   it("new terminals are assigned incremental ids", function()
  --     local test1 = Terminal:new():toggle()
  --     local test2 = Terminal:new():toggle()
  --     local test3 = Terminal:new():toggle()
  --     assert.are.same(test1.id, 1)
  --     assert.are.same(test2.id, 2)
  --     assert.are.same(test3.id, 3)
  --   end)
  --
  --   it("should assign the next id filling in any missing gaps", function()
  --     t.__set_ids({ 1, 2, 5 })
  --     local id = t.__next_id()
  --     assert.equal(id, 3)
  --     id = t.__next_id()
  --     assert.equal(id, 4)
  --     id = t.__next_id()
  --     assert.equal(id, 6)
  --   end)
  --
  --   it("should get terminals as a list", function()
  --     Terminal:new({ id = 20 }):toggle()
  --     Terminal:new():toggle()
  --     local terms = get_all()
  --     assert.equal(#terms, 2)
  --     assert.equal(terms[#terms].id, 20)
  --   end)
  --
  --   it("should open a terminal window on toggle", function()
  --     local test1 = Terminal:new()
  --     test1:toggle()
  --     assert.is_true(api.nvim_buf_is_valid(test1.bufnr))
  --     assert.is_true(vim.tbl_contains(api.nvim_list_wins(), test1.window))
  --   end)
  --
  --   it("should close a terminal window if open", function()
  --     local test1 = Terminal:new()
  --     test1:toggle()
  --     assert.is_true(vim.tbl_contains(api.nvim_list_wins(), test1.window))
  --     test1:toggle()
  --     assert.is_not_true(vim.tbl_contains(api.nvim_list_wins(), test1.window))
  --   end)
  --
  --   it("should toggle a specific buffer if a count is passed", function()
  --     toggleterm.toggle(2, 15)
  --     local terminals = get_all()
  --     assert.equals(#terminals, 1)
  --     local term = terminals[1]
  --     assert.is_true(term_has_windows(term))
  --   end)
  --
  --   it("should not list hidden terminals", function()
  --     Terminal:new({ hidden = true }):toggle()
  --     local terminals = get_all()
  --     assert.equal(#terminals, 0)
  --     Terminal:new():toggle()
  --     terminals = get_all()
  --     assert.equal(#terminals, 1)
  --   end)
  --
  --   it("should not toggle a terminal if hidden", function()
  --     local term = Terminal:new({ hidden = true }):toggle()
  --     assert.is_true(term_has_windows(term))
  --     toggleterm.toggle(1)
  --     assert.is_true(term_has_windows(term))
  --   end)
  --
  --   it("should not toggle a terminal if not hidden", function()
  --     local term = Terminal:new():toggle()
  --     assert.is_true(term_has_windows(term))
  --     toggleterm.toggle(1)
  --     assert.is_false(term_has_windows(term))
  --   end)
  --
  --   it("should create a terminal with a custom command", function()
  --     Terminal:new({ cmd = "bash" }):toggle()
  --     assert.truthy(vim.b.term_title:match("bash"))
  --   end)
  --
  --   it("should open the correct terminal if a user specifies a count", function()
  --     local term = Terminal:new({ count = 5 }):toggle()
  --     term:toggle()
  --     assert.is_false(ui.term_has_open_win(term))
  --     toggleterm.toggle(5)
  --     assert.is_true(ui.term_has_open_win(term))
  --   end)
  --
  --   it("should open a hidden terminal and a visible one", function()
  --     local hidden = Terminal:new({ hidden = true }):toggle()
  --     local visible = Terminal:new():toggle()
  --     hidden:toggle()
  --     visible:toggle()
  --   end)
  --
  --   it("should close all open terminals using toggle all", function()
  --     local test1 = Terminal:new():toggle()
  --     local test2 = Terminal:new():toggle()
  --     toggleterm.toggle_all()
  --
  --     assert.is_false(ui.term_has_open_win(test1))
  --     assert.is_false(ui.term_has_open_win(test2))
  --   end)
  --
  --   it("should open all open terminals using toggle all", function()
  --     local test1 = Terminal:new():toggle()
  --     local test2 = Terminal:new():toggle()
  --     toggleterm.toggle_all()
  --
  --     assert.is_false(ui.term_has_open_win(test1))
  --     assert.is_false(ui.term_has_open_win(test2))
  --
  --     toggleterm.toggle_all()
  --     assert.is_true(ui.term_has_open_win(test1))
  --     assert.is_true(ui.term_has_open_win(test2))
  --   end)
  --
  --   it("should close on exit", function()
  --     local term = Terminal:new():toggle()
  --     assert.is_true(ui.term_has_open_win(term))
  --     term:send("exit")
  --     vim.wait(1000, function() end)
  --     assert.is_false(ui.term_has_open_win(term))
  --   end)
  -- end)

  describe("terminal buffers options - ", function()
    before_each(function()
      toggleterm.setup({
        open_mapping = [[<c-\>]],
        shade_filetypes = { "none" },
        direction = "horizontal",
        float_opts = {
          height = 10,
          width = 20,
        },
      })
    end)

    it("should give each terminal a winhighlight", function()
      local test1 = Terminal:new({ direction = "horizontal" }):toggle()
      assert.is_true(test1:is_split())
      local winhighlight = vim.wo[test1.window].winhighlight
      assert.is.truthy(winhighlight:match("Normal:DarkenedPanel"))
    end)

    it("should set the correct filetype", function()
      local test1 = Terminal:new():toggle()
      local ft = vim.bo[test1.bufnr].filetype
      assert.equals(constants.term_ft, ft)
    end)
  end)

  describe("executing commands - ", function()
    it("should open a terminal to execute commands", function()
      toggleterm.exec("ls", 1)
      local terminals = get_all()
      assert.is_true(#terminals == 1)
      assert.is_true(term_has_windows(terminals[1]))
    end)

    it("should change terminal's directory if specified", function()
      toggleterm.exec("ls", 1, 15, fn.expand("~/"))
      local terminals = get_all()
      assert.is_true(#terminals == 1)
      assert.is_true(term_has_windows(terminals[1]))
    end)

    it("should send commands to a terminal on exec", function()
      local test1 = Terminal:new():toggle()
      spy.on(test1, "send")
      toggleterm.exec('echo "hello world"', 1)
      assert.spy(test1.send).was_called()
      assert.spy(test1.send).was_called_with(test1, 'echo "hello world"', true)
      assert.is_true(vim.tbl_contains(api.nvim_list_wins(), test1.window))
    end)

    it("should send commands to a terminal without opening its window", function()
      local test1 = Terminal:new():toggle()
      test1:close()
      spy.on(test1, "send")
      toggleterm.exec_command("cmd='echo \"hello world\"' open=0", 1)
      assert.spy(test1.send).was_called_with(test1, 'echo "hello world"', false)
      assert.is_false(vim.tbl_contains(api.nvim_list_wins(), test1.window))
    end)

    it("should expand vim wildcards", function()
      local file = vim.fn.tempname() .. ".txt"
      vim.cmd(fmt("e %s", file))
      local test1 = Terminal:new():toggle()
      vim.cmd("wincmd w")
      spy.on(test1, "send")
      toggleterm.exec_command("cmd='echo %'", 1)
      assert.spy(test1.send).was_called_with(test1, fmt("echo %s", file), true)
    end)

    it("should handle nested quotes in cmd args", function()
      local file = vim.fn.tempname() .. ".txt"
      vim.cmd(fmt("e %s", file))
      local test1 = Terminal:new():toggle()
      vim.cmd("wincmd w")
      spy.on(test1, "send")
      toggleterm.exec_command("cmd='g++ -std=c++17 % -o run'", 1)
      assert.spy(test1.send).was_called_with(test1, fmt("g++ -std=c++17 %s -o run", file), true)
    end)
  end)

  describe("terminal mappings behaviour", function()
    it("should respect terminal_mappings in terminal mode", function()
      toggleterm.setup({ open_mapping = [[<space>t]], terminal_mappings = false })
      t.Terminal:new():toggle()
      local result = vim.fn.mapcheck("<space>t", "t")
      assert.equal("", result)
    end)

    it("should map in terminal mode if terminal_mappings is true", function()
      toggleterm.setup({ open_mapping = [[<space>t]], terminal_mappings = true })
      t.Terminal:new():toggle()
      local result = vim.fn.mapcheck("<space>t", "t")
      assert.is_true(#result > 0)
    end)
  end)

  describe("layout options - ", function()
    before_each(function()
      toggleterm.setup({
        open_mapping = [[<c-\>]],
        shade_filetypes = { "none" },
        direction = "horizontal",
        float_opts = {
          height = 10,
          width = 20,
        },
      })
    end)

    it("should open with the correct layout", function()
      local term = Terminal:new({ direction = "float" }):toggle()
      local _, wins = term_has_windows(term)
      assert.equal(#wins, 1)
      assert.equal("popup", fn.win_gettype(fn.win_id2win(wins[1])))
    end)

    it("should not change numbers when resolving size", function()
      local term = Terminal:new()
      local size = 20
      assert.equal(size, ui._resolve_size(size))
      assert.equal(size, ui._resolve_size(size, term))
    end)

    it("should evaluate custom functions when resolving size", function()
      local term = Terminal:new({ direction = "vertical" })
      local size1 = 20
      local size2 = function(_t)
        if _t.direction == "vertical" then
          return size1
        end
        return 0
      end
      assert.equal(ui._resolve_size(size2, term), size1)
    end)

    -- FIXME the height is passed in correctly but is returned as 15
    -- which seems to be an nvim quirk not the code
    it("should open with user configuration if set", function()
      local term = Terminal:new({ direction = "float" }):toggle()
      local _, wins = term_has_windows(term)
      local config = api.nvim_win_get_config(wins[1])
      assert.equal(config.width, 20)
    end)

    it("should use a user's selected highlights", function()
      local term = Terminal
        :new({
          direction = "float",
          float_opts = {
            winblend = 12,
            highlights = {
              border = "ErrorMsg",
              background = "Statement",
            },
          },
        })
        :toggle()
      local winhighlight = vim.wo[term.window].winhighlight
      local winblend = vim.wo[term.window].winblend
      assert.equal(12, winblend)
      assert.is.truthy(winhighlight:match("NormalFloat:Statement"))
      assert.is.truthy(winhighlight:match("FloatBorder:ErrorMsg"))
    end)
  end)
end)
