for i = 1, 100 do
    local name = "DEBUG_SKILL_" .. i
    ICEY2_SKILL_DEFINES[name] = {}
    STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC[name] = {
        TITLE = name,
        DESC = "This is " .. name,
    }
end
