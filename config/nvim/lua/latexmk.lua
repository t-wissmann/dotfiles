
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
    if vim.api.nvim_buf_get_option(0, 'modified') then
        vim.cmd('write') -- write the file
    end
    run_latex_command_for_buffer(function(tex_file)
        return {
            command = 'latexmk',
            args = {'-cd', tex_file},
            title = 'Compiling ' .. vim.fs.basename(tex_file) .. ' via latexmk',
        }
    end)
end

function clean_latex_buffer()
    run_latex_command_for_buffer(function(tex_file)
        return {
            command = 'latexmk',
            args = {'-cd', '-c', tex_file},
            title = 'Cleaning output of ' .. vim.fs.basename(tex_file) .. ' via latexmk',
        }
    end)
end

global_win2commands = {}

--
-- get_invocation on file is a function receiving the main tex file name
-- and it returns a table with fields 'command' and 'args'
--
function run_latex_command_for_buffer(get_invocation)
    winid = vim.fn.win_getid(vim.api.nvim_win_get_number(0))
    if global_win2commands[winid] ~= nil and global_win2commands[winid].outputwin_id == winid then
        -- if the command is run while the output window is focused
        cmd_obj = global_win2commands[winid]
        run_latex_command(0, cmd_obj.tex_file, get_invocation(tex_file))
    else
        parentw_id = 0  -- id of parent window
        find_tex_main_for_buffer(function(tex_file)
            if tex_file == nil or tex_file == '' then
                print('No main tex file found for ' .. vim.api.nvim_buf_get_name(0))
                return
            end
            invocation = get_invocation(tex_file)
            run_latex_command(parentw_id, tex_file, invocation)
        end)
    end
end

function run_latex_command(parentw_id, tex_file, command_invocation)
        local Job = require'plenary.job'
        parentw_id = vim.fn.win_getid(parentw_id) -- normalize window id
        local cmd_obj = global_win2commands[parentw_id]
        if cmd_obj == nil then
            cmd_obj = {
                job = nil,
                outputbuf_id = nil,
                outputwin_id = nil,
                has_outputbuf = function(this)
                    return this.outputbuf_id ~= nil and vim.api.nvim_buf_is_valid(this.outputbuf_id)
                end,
                has_outputwin = function(this)
                    return this.outputwin_id ~= nil and vim.api.nvim_win_is_valid(this.outputwin_id)
                end,
            }
            global_win2commands[parentw_id] = cmd_obj
        end

        cmd_obj.invocation = invocation
        command_str = cmd_obj.invocation.command .. ''  -- force a new copy
        for k, v in pairs(cmd_obj.invocation.args) do
            command_str = command_str .. ' ' .. tostring(v)
        end
        -- see https://neovim.io/doc/user/api.html#api-floatwin
        if not cmd_obj:has_outputbuf() then
            cmd_obj.outputbuf_id = vim.api.nvim_create_buf(false, 'nomodified')
        else
            -- otherwise, clear existing buffer:
            vim.api.nvim_buf_set_lines(cmd_obj.outputbuf_id, 0, -1, false, {})
        end
        vim.api.nvim_buf_set_name(cmd_obj.outputbuf_id, cmd_obj.invocation.title)
        -- vim.api.nvim_buf_delete(0, { unload = true })
        if not cmd_obj:has_outputwin() then
            output_linecount = math.floor(vim.api.nvim_win_get_height(parentw_id) * 0.33)
            cmd_obj.outputwin_id = vim.api.nvim_open_win(cmd_obj.outputbuf_id, false,
              { --relative='win',
                width=vim.api.nvim_win_get_width(parentw_id),
                split='below',
                height=output_linecount,
                -- focusable=true,
                -- style='minimal',
                -- border={ "", "─", "", "", "", "", "", "" },
                -- anchor='NW',
                --bufpos={10000, 0}, -- some ridiculous large numer => glue it to the bottom
                -- title=command_str,
              })
            global_win2commands[cmd_obj.outputwin_id] = cmd_obj
        end
        -- print('Current output window with id ' .. cmd_obj.outputwin_id)
        -- print(command_str)
        job_data = {
          command = cmd_obj.invocation.command,
          args = cmd_obj.invocation.args,
          -- cwd = '/usr/bin',
          -- env = { ['a'] = 'b' },
          on_stderr = function(error, data, j)
            if data ~= nil then
                vim.schedule(function()
                    vim.api.nvim_buf_set_lines(cmd_obj.outputbuf_id, -1, -1, false, {data})
                    vim.api.nvim_win_set_cursor(cmd_obj.outputwin_id, {vim.api.nvim_buf_line_count(cmd_obj.outputbuf_id) - 1, 0})
                end)
            end
          end,
          on_stdout = function(error, data, j)
            if data ~= nil then
                vim.schedule(function()
                    vim.api.nvim_buf_set_lines(cmd_obj.outputbuf_id, -1, -1, false, {data})
                    vim.api.nvim_win_set_cursor(cmd_obj.outputwin_id, {vim.api.nvim_buf_line_count(cmd_obj.outputbuf_id), 0})
                end)
            end
          end,
          on_exit = function(error, exit_code, j)
            if exit_code == 0 then
                vim.defer_fn(function()
                    -- vim.api.nvim_command('messages')
                    vim.api.nvim_win_close(cmd_obj.outputwin_id, false)  -- do not force
                    vim.api.nvim_buf_delete(cmd_obj.outputbuf_id, { unload = true })
                    global_win2commands[parentw_id] = nil
                end, 1200)
            end
          end,
        }
        
        if cmd_obj.job ~= nil then
            cmd_obj.job:shutdown()  -- kill any existing job
            cmd_obj.job = nil
        end
        j = Job:new(job_data)
        cmd_obj.job = j
        j:start()
        --  = Job.new(Job, job_data)
        -- vim.w[outputwin_id].command_job:start() -- do not :sync() or the ui might block
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
