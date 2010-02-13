#include <assert.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

//// windows //////////////////////////////////////////////////////////////////
#ifdef MINGW

// TODO

//// posix ////////////////////////////////////////////////////////////////////
#else

#include <fcntl.h>
#include <signal.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#define PIPE_READ 0
#define PIPE_WRITE 1

#define COMMAND_LENGTH 256

typedef struct {
    int pid;
    int in;
    int out;
    char buf[COMMAND_LENGTH];
    char *read_end;
} ai_t;

static void open_ai(ai_t *ai, char *class)
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

    fcntl(to_subprocess[PIPE_WRITE], F_SETFL, O_NONBLOCK);
    fcntl(from_subprocess[PIPE_READ], F_SETFL, O_NONBLOCK);

    ai->pid = cpid;
    ai->in = to_subprocess[PIPE_WRITE];
    ai->out = from_subprocess[PIPE_READ];
    ai->read_end = ai->buf;
}

static void close_ai(ai_t *ai)
{
    close(ai->in);
    close(ai->out);
    kill(ai->pid, SIGKILL);
    wait(0);
}

static char * find_delim(char *begin, char *end)
{
    char *delim_byte = begin;
    while(delim_byte != end && *delim_byte && *delim_byte != '\n')
        delim_byte++;
    return delim_byte;
}

static char * get_command(ai_t *ai)
{
    // remove old command if there was one
    char * delim_byte = find_delim(ai->buf, ai->read_end);
    if(delim_byte != ai->read_end)
    {
        char *second_command = delim_byte + 1;
        memmove(ai->buf, second_command, ai->read_end - delim_byte);
        ai->read_end -= (second_command - ai->buf);
    }

    // let's try reading
    char *buf_end = ai->buf + COMMAND_LENGTH;
    int count = read(ai->out, ai->read_end, buf_end - ai->read_end);
    if(count > 0)
        ai->read_end += count;
    

    // return the command if there is one
    delim_byte = find_delim(ai->buf, ai->read_end);
    if(delim_byte != ai->read_end)
    {
        *delim_byte = 0;
        return ai->buf;
    }
    else
    {
        return 0;
    }
}

static void send_response(ai_t *ai, const char *response)
{
    // writing is done on a best-effort basis, if the AI doesn't keep it's
    // buffer clean then too bad for it
    write(ai->in, response, strlen(response));
    write(ai->in, "\n", 1);
}

#endif

//// lua //////////////////////////////////////////////////////////////////////

#define AI_MT "ai_loader.ai"

static void load_ai(lua_State *L, char *class)
{
    ai_t *ai = (ai_t *)lua_newuserdata(L, sizeof(ai_t));
    luaL_getmetatable(L, AI_MT);
    lua_setmetatable(L, -2);

    open_ai(ai, class);
}

// ai
static int ai__get_command(lua_State *L)
{
    ai_t *ai = (ai_t *)luaL_checkudata(L, 1, AI_MT);
    lua_pushstring(L, get_command(ai));
    return 1;
}

static int ai__send_response(lua_State *L)
{
    ai_t *ai = (ai_t *)luaL_checkudata(L, 1, AI_MT);
    const char *response = luaL_checkstring(L, 2);
    send_response(ai, response);
    return 1;
}

static int ai__gc(lua_State *L)
{
    ai_t *ai = (ai_t *)luaL_checkudata(L, 1, AI_MT);
    close_ai(ai);
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
    {"get_command", ai__get_command},
    {"send_response", ai__send_response},
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

