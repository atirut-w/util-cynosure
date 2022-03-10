--!lua

--- https://raw.githubusercontent.com/philanc/plc/master/plc/sha3.lua
local sha3 = assert(load(
    [[local a=string.char;local b=table.concat;local c,d=string.pack,string.unpack;local e=24;local f={0x0000000000000001,0x0000000000008082,0x800000000000808A,0x8000000080008000,0x000000000000808B,0x0000000080000001,0x8000000080008081,0x8000000000008009,0x000000000000008A,0x0000000000000088,0x0000000080008009,0x000000008000000A,0x000000008000808B,0x800000000000008B,0x8000000000008089,0x8000000000008003,0x8000000000008002,0x8000000000000080,0x000000000000800A,0x800000008000000A,0x8000000080008081,0x8000000000008080,0x0000000080000001,0x8000000080008008}local g={{0,36,3,41,18},{1,44,10,45,2},{62,6,43,15,61},{28,55,25,21,56},{27,20,39,8,14}}local function h(i)local j=i.permuted;local k=i.parities;for l=1,e do for m=1,5 do k[m]=0;local n=i[m]for o=1,5 do k[m]=k[m]~n[o]end end;local p,q,r;p=k[2]q=k[5]~(p<<1|(p>>63))r=i[1]for o=1,5 do r[o]=r[o]~q end;p=k[3]q=k[1]~(p<<1|(p>>63))r=i[2]for o=1,5 do r[o]=r[o]~q end;p=k[4]q=k[2]~(p<<1|(p>>63))r=i[3]for o=1,5 do r[o]=r[o]~q end;p=k[5]q=k[3]~(p<<1|(p>>63))r=i[4]for o=1,5 do r[o]=r[o]~q end;p=k[1]q=k[4]~(p<<1|(p>>63))r=i[5]for o=1,5 do r[o]=r[o]~q end;for o=1,5 do local s=j[o]local t;for m=1,5 do r,t=i[m][o],g[m][o]s[(2*m+3*o)%5+1]=r<<t|(r>>64-t)end end;local u,v,w;r,u,v,w=i[1],j[1],j[2],j[3]for o=1,5 do r[o]=u[o]~(~v[o]&w[o])end;r,u,v,w=i[2],j[2],j[3],j[4]for o=1,5 do r[o]=u[o]~(~v[o]&w[o])end;r,u,v,w=i[3],j[3],j[4],j[5]for o=1,5 do r[o]=u[o]~(~v[o]&w[o])end;r,u,v,w=i[4],j[4],j[5],j[1]for o=1,5 do r[o]=u[o]~(~v[o]&w[o])end;r,u,v,w=i[5],j[5],j[1],j[2]for o=1,5 do r[o]=u[o]~(~v[o]&w[o])end;i[1][1]=i[1][1]~f[l]end end;local function x(i,y)local z=i.rate/8;local A=z/8;local B=#y+1;y=y..'\x06'..a(0):rep(z-B%z)B=#y;local C={}for D=1,B-B%8,8 do C[#C+1]=d('<I8',y,D)end;local E=#C;C[E]=C[E]|0x8000000000000000;for F=1,E,A do local G=0;for o=1,5 do for m=1,5 do if G<A then local H=F+G;i[m][o]=i[m][o]~C[H]G=G+1 end end end;h(i)end end;local function I(i)local z=i.rate/8;local A=z/4;local J={}local G=1;for o=1,5 do for m=1,5 do if G<A then J[G]=c("<I8",i[m][o])G=G+1 end end end;return b(J)end;local function K(L,M,N)local O={{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}}O.rate=L;O.permuted={{},{},{},{},{}}O.parities={0,0,0,0,0}x(O,N)return I(O):sub(1,M/8)end;local function P(N)return K(1088,256,N)end;local function Q(N)return K(576,512,N)end;return{sha256=P,sha512=Q}]],
    "=sha3", "t", _G
))()

---@param hash string
local function hash2hex(hash)
    return hash:gsub(".", function(c)
        return string.format("%02x", string.byte(c))
    end)
end

---@param hex string
local function hex2hash(hex)
    return hex:gsub("..", function(c)
        return string.char(tonumber(c, 16))
    end)
end

--- Perform a system call
---@param call string
---@vararg any
local function syscall(call, ...)
  return coroutine.yield("syscall", call, ...)
end

---@param line string
local function parse_account(line)
    local username, pwhash, uid, gid, gecos, home, shell = line:match("^([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)$")
    if username and pwhash and uid and gid and gecos and home and shell then
        return {
            username = username,
            pwhash = pwhash,
            uid = tonumber(uid),
            gid = tonumber(gid),
            gecos = gecos,
            home = home,
            shell = shell
        }
    end
end

---@param fmt string
---@vararg any
local function printf(fmt, ...)
  syscall("write", 1, string.format(fmt, ...))
end

---@return string
local function readline()
  return syscall("read", 0, "l")
end

while true do
    printf("Login: ")
    local username = readline()
    printf("Password: \27[8m")
    local password = readline()
    printf("\27[28m\n")

    ---@type string
    local passwd
    do
        local fd, errno = syscall("open", "/etc/passwd", "r")
        if not fd then
            printf("Failed to open /etc/passwd: %s\n\n", errno)
            syscall("exit", 1)
        end
        passwd = syscall("read", fd, "a")
        syscall("close", fd)
    end

    local account = nil
    for line in passwd:gmatch("[^\r\n]+") do
        local acc = parse_account(line)

        if acc and acc.username == username then
            local inputhash = hash2hex(sha3.sha512(password))
            if inputhash == acc.pwhash then
                account = acc
                break
            end
        end
    end

    if not account then
        printf("Login incorrect\n\n")
    else
        local pid = syscall("fork", function()
            local s, errno = syscall("setuid", account.uid)
            if not s then
                printf("Failed to set UID: %s\n", errno)
                syscall("exit", 1)
            end
            local _, errno = syscall("execve", account.shell, {}, {})
            if errno then
                printf("Could not execute %s: %d\n\n", account.shell, errno)
            end
        end)
        syscall("wait", pid)
        syscall("exit", 0)
    end
end
