# fitech core
## Global
+ `ft.mod_name(): string` - returns current loading modname
+ `ft.world_path(): string` - returns current worldpath
+ `ft.get_dirs(path: string): string` - returns array of directories at path
+ `ft.get_files(path: string): string` - returns array of files at path
+ `ft.mod_path(modname: string?): string` - returns mod location by providing it's name, if name is absent using current mod
+ `ft.mod_load(path: string): any?` - load and return result of `dofile` using current mod location and path
+ `ft.bulk_load(container: {}, rootpath: string): {}` - gets all files and directories and loads them to `container`. Don't recommend to use if there many files depends on each other.

## Vendors
+ [Nex](vendors/nex/README.md)