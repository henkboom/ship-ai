#include <assert.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

static int ai_loader__load_all(lua_State *L)
{
    lua_newtable(L);
    return 1;
}

static const luaL_reg ai_lib[] =
{
    {NULL, NULL}
};

static const luaL_Reg ai_loader_lib[] =
{
    {"load_all", ai_loader__load_all},
    {NULL, NULL}
};

int luaopen_ai_loader(lua_State *L)
{
    luaL_newmetatable(L, "ai_loader.ai");
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    luaL_register(L, NULL, ai_lib);

    lua_newtable(L);
    luaL_register(L, NULL, ai_loader_lib);
    return 1;
}

