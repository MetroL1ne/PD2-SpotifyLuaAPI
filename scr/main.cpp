#include <superblt_flat.h>
#include <windows.h>
#include <TlHelp32.h>

// 通过进程名获取主窗口句柄
HWND FindMainWindowByProcessName(const wchar_t* processName) {
	DWORD pid = 0;
	HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	if (hSnapshot != INVALID_HANDLE_VALUE) {
		PROCESSENTRY32W pe32;
		pe32.dwSize = sizeof(PROCESSENTRY32W);
		if (Process32FirstW(hSnapshot, &pe32)) {
			do {
				if (_wcsicmp(pe32.szExeFile, processName) == 0) {
					pid = pe32.th32ProcessID;
					break;
				}
			} while (Process32NextW(hSnapshot, &pe32));
		}
		CloseHandle(hSnapshot);
	}
	if (pid == 0) return NULL;

	// 通过进程ID获取窗口句柄
	HWND hwnd = NULL;
	while ((hwnd = FindWindowExW(NULL, hwnd, NULL, NULL)) != NULL) {
		DWORD windowPid;
		GetWindowThreadProcessId(hwnd, &windowPid);
		if (windowPid == pid) {
			wchar_t title[256];
			GetWindowTextW(hwnd, title, 256);
			if (wcsstr(title, L" - ") != NULL) {  // 检查是否是播放窗口
				return hwnd;
			}
		}
	}
	return NULL;
}

// NetEase
int GetNetEaseMusicNowPlaying(lua_State* L) {
	HWND hwnd = FindWindowA("OrpheusBrowserHost", nullptr);
	if (!hwnd) {
		lua_pushstring(L, "ERROR_WINDOW");
		return 1;
	}

	wchar_t title[256];
	GetWindowTextW(hwnd, title, 256);

	// To UTF-8
	char utf8Title[512];
	WideCharToMultiByte(CP_UTF8, 0, title, -1, utf8Title, 512, NULL, NULL);

	lua_pushstring(L, utf8Title);

	return 1;
}

// Spotify
int GetSpotifyNowPlaying(lua_State* L) {
	HWND hwnd = FindMainWindowByProcessName(L"Spotify.exe");
	if (hwnd) {
		wchar_t title[256];
		GetWindowTextW(hwnd, title, 256);

		// To UTF-8
		char utf8Title[512];
		WideCharToMultiByte(CP_UTF8, 0, title, -1, utf8Title, 512, NULL, NULL);

		lua_pushstring(L, utf8Title);
	}
	else {
		lua_pushstring(L, "ERROR_WINDOW");
	}
	return 1;
}

/* 以下是SuperBLT API内容 */

void Plugin_Init()
{
	PD2HOOK_LOG_LOG("NetEaseLuaAPI loaded successfully.");
}

void Plugin_Update()
{
}

void Plugin_Setup_Lua(lua_State* L)
{
}

int Plugin_PushLua(lua_State* L)
{
	lua_newtable(L);

	lua_pushcfunction(L, GetNetEaseMusicNowPlaying);
	lua_setfield(L, -2, "NetEase_NowPlaying");

	lua_pushcfunction(L, GetSpotifyNowPlaying);
	lua_setfield(L, -2, "Spotify_NowPlaying");

	return 1;
}