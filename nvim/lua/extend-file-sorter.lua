local extending = {
    current_file = nil,
    current_file_altered_prompt = nil,
}

extending.start = function ()
    extending.current_file = vim.fn.expand('%:~:.')
    extending.current_file_altered_prompt = vim.fn.fnamemodify(extending.current_file, ':t:r')
end

extending.wrap = function (file_sorter_factory)
    return function (opts)
        local sorter = file_sorter_factory(opts)

        local original_scoring_function = sorter.scoring_function
        sorter.scoring_function = function (self, prompt, line)
            if prompt ~= "" or extending.current_file == nil then
                return original_scoring_function(self, prompt, line)
            end

            if extending.current_file == line then
                return 2
            end

            local ret = original_scoring_function(self, extending.current_file_altered_prompt, line)
            if ret <= 0 then
                return 1
            end

            return ret
        end

        return sorter
    end
end

return extending
