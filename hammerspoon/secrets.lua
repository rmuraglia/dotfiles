-- NOTE: For work related convenience functions that may contain work-related project names or URLs, this file provides a safer place to store them that should not get synced upstream to git

function superPaste()
    -- common enhancements to paste for markdown, like:
    -- 1) if you copied a jira URL for a ticket (PROJECT-num), then paste it formatted like [PROJECT-num](URL)
    -- 2) if you copied a github PR URL, then paste it formatted like [REPO#ddd](URL)

    local copiedText = hs.pasteboard.getContents()

    local jiraPattern = '/(%a+-%d+)$'
    local jiraMatch = string.match(copiedText, jiraPattern)

    local gitPattern = '([%w-]+)/pull/(%d+)'
    local gitMatchRepo, gitMatchNum = string.match(copiedText, gitPattern)

    if jiraMatch ~= nil then
        ret = '[' .. jiraMatch .. '](' .. copiedText .. ')'
    elseif gitMatchRepo ~= nil and gitMatchNum ~= nil then
        ret = '[' .. gitMatchRepo .. '#' .. gitMatchNum .. '](' .. copiedText .. ')'
    else
        ret = copiedText
    end

    hs.eventtap.keyStrokes(ret)
end
