SET CURRENT_PATH_PREINSTALL=%CD%
SET TURBO_ROOT=C:\turbo.lua
SET TURBO_LUAROCKS=%TURBO_ROOT%\luarocks
SET TURBO_LUAROCKS_BIN=%TURBO_LUAROCKS%\2.2
SET TURBO_ROCKS=%TURBO_ROOT%\rocks
SET TURBO_SRC=%TURBO_ROOT%\src
SET TURBO_OPENSSL_ROOT=%TURBO_ROOT%\OpenSSL
SET VCVARSALL_BAT="C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"

echo ===========================
echo Thank you for trying Turbo.lua
echo This script will use Chocolatey to install dependencies. If they are already installed they will be skipped.
echo Current dependencies are:
echo Visual Studio 2013, Git, Mingw, Gnuwin, Strawberry Perl (to compile OpenSSL).
echo Please abort installation now by clicking CTRL+C within 10 seconds.
echo ===========================
timeout /t 10

setx PATH "%PATH%;%TURBO_ROOT%;%TURBO_LUAROCKS_BIN" /M
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
choco install -y visualstudio2013professional git mingw gnuwin strawberryperl
call %VCVARSALL_BAT% amd64
SET PATH=%PATH%;%TURBO_ROOT%;%TURBO_LUAROCKS_BIN;C:\Program Files (x86)\Git\cmd;C:\GnuWin\bin;C:\tools\mingw64\bin;C:\Program Files (x86)\Windows Kits\8.1\bin\x64
rm -rf %TURBO_ROOT%
mkdir %TURBO_ROOT%
cd %TURBO_ROOT%
mkdir src
cd src

echo ===========================
echo Now building Turbo.lua C helper functions
echo ===========================
git clone https://github.com/kernelsauce/turbo.git
cd %TURBO_SRC%\turbo
mingw32-make SSL=none
mv libtffi_wrap.so libtffi_wrap.dll
setx TURBO_LIBTFFI "%TURBO_SRC%\turbo\libtffi_wrap.dll" /M
setx TURBO_LIBSSL "%TURBO_OPENSSL_ROOT%\lib\libeay32.dll" /M
SET TURBO_LIBTFFI=%TURBO_SRC%\turbo\libtffi_wrap.dll
SET TURBO_LIBSSL=%TURBO_OPENSSL_ROOT%\lib\libeay32.dll

echo ===========================
echo Now building OpenSSL from source to support SSL in Turbo.lua
echo ===========================
cd %TURBO_SRC%
wget DownloadFile https://www.openssl.org/source/openssl-1.0.2c.tar.gz
7z x openssl-1.0.2c.tar.gz
7z x openssl-1.0.2c.tar
cd openssl-1.0.2c
perl Configure VC-WIN64A --prefix=%OPENSSL_ROOT%
ms\do_win64a
nmake -f ms\nt.mak
nmake -f ms\nt.mak install

echo ===========================
echo Now building LuaJIT 2.
echo ===========================
cd %TURBO_SRC%
git clone http://luajit.org/git/luajit-2.0.git
cd %TURBO_SRC%\luajit-2.0\src
call msvcbuild
cp luajit.exe %TURBO_ROOT%
cp lua51.dll %TURBO_ROOT%

echo ===========================
echo Now downloading LuaRocks. A Lua package manager.
echo ===========================
cd %TURBO_SRC%
git clone https://github.com/keplerproject/luarocks.git
cd %TURBO_SRC%\src\luarocks
SET LUA_PATH=%TURBO_ROCKS%\share\lua\5.1\?.lua;%TURBO_ROCKS%\share\lua\5.1\?\init.lua;%TURBO_SRC%\turbo\?.lua;%TURBO_SRC%\turbo\turbo\?.lua
SET LUA_CPATH=%TURBO_ROCKS%\lib\lua\5.1\?.dll
setx LUA_PATH "%LUA_PATH%" /M
setx LUA_CPATH "%LUA_CPATH%" /M
call install.bat /TREE %TURBO_ROCKS% /P %TURBO_LUAROCKS% /INC %TURBO_SRC%\luajit-2.0\src /LIB %TURBO_SRC%\luajit-2.0\src /LUA %TURBO_ROOT% /Q
call luarocks install luasocket
call luarocks install luafilesystem

echo ===========================
echo Now compiling LuaSec for SSL support.
echo ===========================
cd %TURBO_SRC%
git clone https://github.com/kernelsauce/luasec.git
cd luasec
call luarocks make luasec-0.5-3.rockspec OPENSSL_INCDIR=%TURBO_OPENSSL_ROOT%\include OPENSSL_LIBDIR=%TURBO_OPENSSL_ROOT%\lib

cd %CURRENT_PATH_PREINSTALL%
echo ===========================
echo Turbo is now installed. Try it by running 'luajit %TURBO_SRC%\turbo\examples\helloworld.lua' and point your browser to http://localhost:8888.
echo Have a nice day!
echo ===========================
pause

