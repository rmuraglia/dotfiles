-- display alternate layouts for colemak dhm transition as alert for quick peek
alt_layouts = {}

alt_layouts['tarmak1'] = [[
,-------------------.      ,-------------------.
| Q | W | J | R | T |      | Y | U | I | O | P |
|---+---+---+---+---|      |---+---+---+---+---|
| A | S | D | F | G |      | M | N | E | L | ' |
|---+---+---+---+---|      |---+---+---+---+---|
| Z | X | C | V | B |      | K | H | , | . | / |
`-------------------/      \-------------------']]

alt_layouts['tarmak2'] = [[
,-------------------.      ,-------------------.
| Q | W | F | R | B |      | Y | U | I | O | P |
|---+---+---+---+---|      |---+---+---+---+---|
| A | S | D | T | G |      | M | N | E | L | ' |
|---+---+---+---+---|      |---+---+---+---+---|
| Z | X | C | J | V |      | K | H | , | . | / |
`-------------------/      \-------------------']]

alt_layouts['tarmak3'] = [[
,-------------------.      ,-------------------.
| Q | W | F | J | B |      | Y | U | I | O | P |
|---+---+---+---+---|      |---+---+---+---+---|
| A | R | S | T | G |      | M | N | E | L | ' |
|---+---+---+---+---|      |---+---+---+---+---|
| Z | X | C | D | V |      | K | H | , | . | / |
`-------------------/      \-------------------']]

alt_layouts['tarmak4'] = [[
,-------------------.      ,-------------------.
| Q | W | F | P | B |      | J | U | I | Y | ' |
|---+---+---+---+---|      |---+---+---+---+---|
| A | R | S | T | G |      | M | N | E | L | O |
|---+---+---+---+---|      |---+---+---+---+---|
| Z | X | C | D | V |      | K | H | , | . | / |
`-------------------/      \-------------------']]

alt_layouts['colemak-dhm'] = [[
,-------------------.      ,-------------------.
| Q | W | F | P | B |      | J | L | U | Y | ' |
|---+---+---+---+---|      |---+---+---+---+---|
| A | R | S | T | G |      | M | N | E | I | O |
|---+---+---+---+---|      |---+---+---+---+---|
| Z | X | C | D | V |      | K | H | , | . | / |
`-------------------/      \-------------------']]

function showLayout(layout, duration)
    local layoutMonospace = hs.styledtext.new(layout, {
        font={name='Monaco', size=27},
        color=hs.drawing.color.hammerspoon['white']
    })
    for _, screen in pairs(screens) do
        hs.alert.show(layoutMonospace, {fillColor={alpha=1}, atScreenEdge=2}, screen, duration)
    end
end