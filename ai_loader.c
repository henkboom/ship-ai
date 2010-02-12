#include <assert.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

//// Posix

#include <signal.h>
#include <sys/types.h>
#include <unistd.h>

#define PIPE_READ 0
#define PIPE_WRITE 1

void open_process(int *pid, int *in, int *out, char *class)
{
    int to_subprocess[2];
    int from_subprocess[2];
    pid_t cpid;

    if (pipe(to_subprocess) == -1 || pipe(from_subprocess) == -1) {
        perror("pipe");
        _exit(1);
    }

    cpid = fork();
    if (cpid == -1) {
        perror("fork");
        _exit(1);
    }

    // subprocess
    if (cpid == 0) {
        // close unused pipe ends
        close(to_subprocess[PIPE_WRITE]);
        close(from_subprocess[PIPE_READ]);

        // replace stdin and stdout
        dup2(to_subprocess[PIPE_READ], STDIN_FILENO);
        dup2(from_subprocess[PIPE_WRITE], STDOUT_FILENO);

        // run the program
        execl("/usr/bin/java", "java", "-cp", "classes", class, NULL);

        // if execl returned then something failed
        perror("execl");
        _exit(1);
    }

    // back in the main process
    close(to_subprocess[PIPE_READ]);
    close(from_subprocess[PIPE_WRITE]);

    *pid = cpid;
    *in = to_subprocess[PIPE_WRITE];
    *out = from_subprocess[PIPE_READ];
}

void close_process(int pid)
{
    kill(pid, SIGKILL);
}

#define AI_MT "ai_loader.ai"

typedef struct {
    int pid;
    int in;
    int out;
} ai_t;

static void load_ai(lua_State *L, char *class)
{
    ai_t *ai = (ai_t *)lua_newuserdata(L, sizeof(ai_t));
    luaL_getmetatable(L, AI_MT);
    lua_setmetatable(L, -2);

    open_process(&ai->pid, &ai->in, &ai->out, class);
}

// ai
static int ai__gc(lua_State *L)
{
    ai_t *ai = (ai_t *)luaL_checkudata(L, 1, AI_MT);
    close_process(ai->pid);
    return 0;
}

// ai_loader
static int ai_loader__load_all(lua_State *L)
{
    lua_newtable(L);

    load_ai(L, "TestAI");
    lua_rawseti(L, -2, 1);

    return 1;
}

static const luaL_reg ai_lib[] =
{
    {"__gc", ai__gc},
    {NULL, NULL}
};

static const luaL_Reg ai_loader_lib[] =
{
    {"load_all", ai_loader__load_all},
    {NULL, NULL}
};

int luaopen_ai_loader(lua_State *L)
{
    luaL_newmetatable(L, AI_MT);
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    luaL_register(L, NULL, ai_lib);

    lua_newtable(L);
    luaL_register(L, NULL, ai_loader_lib);
    return 1;
}

