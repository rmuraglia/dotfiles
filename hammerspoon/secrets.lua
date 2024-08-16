-- NOTE: For work related convenience functions that may contain work-related project names or URLs, this file provides a safer place to store them that should not get synced upstream to git

function superPaste()
    -- common enhancements to paste for markdown, like:
    -- 1) if you copied a jira URL for a ticket (PROJECT-num), then paste it formatted like [PROJECT-num](URL)
    -- 2) if you copied a github PR URL, then paste it formatted like [REPO#ddd](URL)
    -- 3) if you copied a slack URL, then paste it as [slack](URL)

    local copiedText = hs.pasteboard.getContents()

    local jiraPattern = '/(%a+-%d+)$'
    local jiraMatch = string.match(copiedText, jiraPattern)

    local gitPattern = '([%w-]+)/pull/(%d+)'
    local gitMatchRepo, gitMatchNum = string.match(copiedText, gitPattern)
    
    local slackPattern = 'slack.com/archives/'
    local slackMatch = string.match(copiedText, slackPattern)

    if jiraMatch ~= nil then
        ret = '[' .. jiraMatch .. '](' .. copiedText .. ')'
    elseif gitMatchRepo ~= nil and gitMatchNum ~= nil then
        ret = '[' .. gitMatchRepo .. '#' .. gitMatchNum .. '](' .. copiedText .. ')'
    elseif slackMatch ~= nil then
        ret = '[slack](' .. copiedText .. ')'
    else
        ret = copiedText
    end

    hs.eventtap.keyStrokes(ret)
end
