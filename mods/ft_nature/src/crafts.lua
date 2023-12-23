local Recipe = ft.recipe.Recipe

Recipe("ft:mt_craft", {
    type = "shapeless",
    output = "ft_nature:block_oak_planks 4",
    recipe = { "ft_nature:block_oak_log" }
}):register("1_oak_log_to_4_oak_planks")

Recipe("ft:mt_craft", {
    type = "shapeless",
    output = "ft_nature:block_birch_planks 4",
    recipe = { "ft_nature:block_birch_log" }
}):register("1_birch_log_to_4_birch_planks")