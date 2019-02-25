data:extend({
    {
        type = "selection-tool",
        name = "pollution-calc",
        icon = "__PollutionCalculator__/graphics/icon.png",
        icon_size = 64,
        flags = {"hidden"},
        subgroup = "tool",
        order = "c[selection-tool]-a[pollution-calc]",
        stack_size = 1,
        stackable = false,
        selection_color = {r = 1, g = 0, b = 0},
        alt_selection_color = {r = 0, g = 1, b = 0},
        selection_mode = {"buildable-type"},
        alt_selection_mode = {"buildable-type"},
        selection_cursor_box_type = "copy",
        alt_selection_cursor_box_type = "copy",
        always_include_tiles = false,
        show_in_library = true
    }
})