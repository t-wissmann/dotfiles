table.insert(binds.commands, lousy.bind.cmd("inc[rease]", function (w, addend)
        local uri = w:get_current().uri
        local from, to
        local next_from, next_to
        -- find first match for a number
        next_from,next_to = string.find(uri, "%d+")
        while next_from and next_to do
            from, to = next_from, next_to
            -- find next match
            next_from,next_to = string.find(uri, "%d+", to+1)
        end
        -- if we found a match
        if from and to then
            local number = string.sub(uri, from, to) -- get number from uri
            if type(tonumber(addend)) ~= "number" then
                addend = 1
            end
            number = number + tonumber(addend);               -- increase number
            local number_len = to - from + 1
            -- compose new uri
            local new_uri = ""
            -- prepend part before number
            if from > 0 then
                new_uri = new_uri..string.sub(uri, 0, from - 1)
            end
            -- append the increased number
            new_uri = new_uri..string.format("%0"..number_len.."d", number)
            -- append part after number
            uri_len = string.len(uri)
            new_uri = new_uri..string.sub(uri, to + 1, uri_len)
            -- now load uri in browser
            w:navigate(new_uri)
        end
    end))


