
function make_path_relative(filepath)
    local p = require'plenary.path'
    return p:new(filepath):make_relative()
end


function find_tex_main(source_file_path)
    --- try to find the main tex file for the given source file
    --- which is possible included in some other tex file.
    --- returns nil if no main file is found
    local command = {}
    -- table.insert(command, '--print-all')
    -- add all open files as candidates:
    table.insert(command, '--candidates')
    --- from https://codereview.stackexchange.com/a/282183
    for i, buf_hndl in ipairs(vim.api.nvim_list_bufs()) do
        table.insert(command, vim.api.nvim_buf_get_name(buf_hndl))
    end
    table.insert(command, '--')
    -- add the needle:
    table.insert(command, source_file_path)
    -- run the command:
    local Job = require'plenary.job'
    local command_path = vim.fn.stdpath("config") .. '/find-tex-main.py'

    -- alternatively: local output = vim.fn.system { 'echo', 'hi' }
    job_stdout = ''
    Job:new({
      command = command_path,
      args = command,
      -- cwd = '/usr/bin',
      -- env = { ['a'] = 'b' },
      on_stderr = function(error, data, j)
          if data ~= nil then
            print(data)
          end
      end,
      on_stdout = function(error, more_job_stdout, j)
        job_stdout = job_stdout .. more_job_stdout
        -- print(job_stdout)
        -- vim.b[bufnr].main_tex_file = job_stdout
      end,
    }):sync()
    if job_stdout == '' then
        job_stdout = nil
    end
    return job_stdout
end

function find_tex_main_for_buffer(action_on_main_tex_file)
    bufnr = 0
    tex_file = vim.api.nvim_buf_get_name(bufnr)
    if vim.b[bufnr].main_tex_file ~= nil then
        action_on_main_tex_file(vim.b[bufnr].main_tex_file)
        return
    end
    if vim.b[bufnr].main_tex_file == nil then
        main_tex_file = find_tex_main(tex_file)
        if main_tex_file ~= tex_file then
            print('Auto detected main tex file ' .. make_path_relative(main_tex_file) .. ' for ' .. make_path_relative(tex_file))
        end
        if main_tex_file ~= nil then
            vim.b[bufnr].main_tex_file = main_tex_file
            action_on_main_tex_file(main_tex_file)
            return
        end
    end
    -- if still no main tex file has been found,
    -- then ask the user whether the buffer itself is the
    -- main tex file
    if vim.b[bufnr].main_tex_file == nil then
        vim.ui.input({
            prompt = "Enter the main tex file for " .. vim.fs.basename(tex_file) .. ": ",
            default = tex_file,
            completion = 'file',
        }, function(input)
            print(' ')
            if input ~= nil and input ~= '' then
                vim.b[bufnr].main_tex_file = input
                action_on_main_tex_file(input)
            end
        end)
    end
end

function build_latex_buffer()
    find_tex_main_for_buffer(function(tex_file)
        if tex_file == nil or tex_file == '' then
            print('No main tex file found for ' .. vim.api.nvim_buf_get_name(0))
            return
        end
        local Job = require'plenary.job'
        parentw = 0

        -- alternatively: local output = vim.fn.system { 'echo', 'hi' }
        -- print('Compiling ' .. tex_file)
        command = 'latexmk'
        args = {'-cd', tex_file}
        command_str = command .. ''  -- force a new copy
        for k, v in pairs(args) do
            command_str = command_str .. ' ' .. tostring(v)
        end
        -- see https://neovim.io/doc/user/api.html#api-floatwin
        if vim.w[parentw].command_output_buf ~= nil and vim.api.nvim_buf_is_valid(vim.w[parentw].command_output_buf) then
            outputbuf = vim.w[parentw].command_output_buf
        else
            outputbuf = vim.api.nvim_create_buf(false, 'nomodified')
            vim.w[parentw].command_output_buf = outputbuf
        end
        vim.api.nvim_buf_set_name(outputbuf, command)
        -- vim.api.nvim_buf_delete(0, { unload = true })
        output_linecount = 5
        if vim.w[parentw].command_output_win ~= nil and vim.api.nvim_win_is_valid(vim.w[parentw].command_output_win) then
            outputwin = vim.w[parentw].command_output_win
        else
            outputwin = vim.api.nvim_open_win(outputbuf, false,
              { --relative='win',
                width=vim.api.nvim_win_get_width(0),
                split='below',
                height=output_linecount,
                -- focusable=true,
                -- style='minimal',
                -- border={ "", "─", "", "", "", "", "", "" },
                -- anchor='NW',
                --bufpos={10000, 0}, -- some ridiculous large numer => glue it to the bottom
                -- title=command_str,
              })
            vim.w[parentw].command_output_win = outputwin
            vim.w[outputwin].command_output_win = outputwin
            vim.w[outputwin].command_output_buf = outputbuf
        end
        -- print(command_str)
        Job:new({
          command = command,
          args = args,
          -- cwd = '/usr/bin',
          -- env = { ['a'] = 'b' },
          on_stderr = function(error, data, j)
            if data ~= nil then
                vim.schedule(function()
                    vim.api.nvim_buf_set_lines(outputbuf, -1, -1, false, {data})
                    vim.api.nvim_win_set_cursor(outputwin, {vim.api.nvim_buf_line_count(outputbuf) - 1, 0})
                end)
            end
          end,
          on_stdout = function(error, data, j)
            if data ~= nil then
                vim.schedule(function()
                    vim.api.nvim_buf_set_lines(outputbuf, -1, -1, false, {data})
                    vim.api.nvim_win_set_cursor(outputwin, {vim.api.nvim_buf_line_count(outputbuf), 0})
                end)
            end
          end,
          on_exit = function(error, exit_code, j)
            if exit_code == 0 then
                vim.defer_fn(function()
                    -- vim.api.nvim_command('messages')
                      vim.api.nvim_win_close(outputwin, false)  -- do not force
                      vim.api.nvim_buf_delete(outputbuf, { unload = true })
                      vim.w[parentw].command_output_win = nil
                      vim.w[parentw].command_output_buf = nil
                end, 1200)
            end
          end,
        }):start() -- do not :sync() or the ui might block
    end)
end

-- For debugging:
-- vim.lsp.set_log_level('debug')
-- and then run: tail -f ~/.local/state/nvim/lsp.log
function TexlabShowDependencyGraph()
    t = "called"
    -- vim.lsp.buf.execute_command({
    --   command = "texlab.showDependencyGraph",
    --   arguments = {},
    -- })
    function handler(err, result, ctx, config)
        print(result or err)
        t = result
    end
    cmd_and_args = {
      command = "texlab.showDependencyGraph",
      -- command = {"texlab.cleanArtifacts"},
      arguments = {},
      -- workDoneToken = {"some-arbitrary-text"},
    }
    res = vim.lsp.buf_request(0, 'workspace/executeCommand', cmd_and_args, handler)
end
