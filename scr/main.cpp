#include <superblt_flat.h>
#include <windows.h>
#include <TlHelp32.h>

// 异步查找状态
static bool g_spotifySearching = false;
static HWND g_spotifyResult = NULL;
static HANDLE g_spotifyThread = NULL;

// Spotify异步查找线程
DWORD WINAPI SpotifyFindThread(LPVOID) {
	DWORD pid = 0;
	HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	if (hSnapshot != INVALID_HANDLE_VALUE) {
		PROCESSENTRY32W pe32;
		pe32.dwSize = sizeof(PROCESSENTRY32W);
		if (Process32FirstW(hSnapshot, &pe32)) {
			do {		
				if (_wcsicmp(pe32.szExeFile, L"Spotify.exe") == 0) {
					pid = pe32.th32ProcessID;
					break;
				}
			} while (Process32NextW(hSnapshot, &pe32));
		}
		CloseHandle(hSnapshot);
	}

	if (pid != 0) {
		HWND hwnd = NULL;
		while ((hwnd = FindWindowExW(NULL, hwnd, NULL, NULL)) != NULL) {
			DWORD windowPid;
			GetWindowThreadProcessId(hwnd, &windowPid);
			if (windowPid == pid) {
				wchar_t title[256];
				GetWindowTextW(hwnd, title, 256);
				if (wcsstr(title, L" - ") != NULL) {
					g_spotifyResult = hwnd;
					break;
				}
			}
		}
	}

	return 0;
}

// 启动Spotify异步查找
void StartSpotifyAsyncFind() {
	if (g_spotifySearching) {
		return;
	}

	g_spotifySearching = true;
	g_spotifyResult = NULL;
	g_spotifyThread = CreateThread(NULL, 0, SpotifyFindThread, NULL, 0, NULL);
}

// Spotify
int GetSpotifyNowPlaying(lua_State* L) {
	// 先启动异步查找（如果还没开始的话）
	if (!g_spotifySearching) {
		StartSpotifyAsyncFind();
	}

	// 检查查找状态
	if (g_spotifySearching) {
		if (WaitForSingleObject(g_spotifyThread, 0) == WAIT_OBJECT_0) {
			// 查找完成
			CloseHandle(g_spotifyThread);
			g_spotifyThread = NULL;
			g_spotifySearching = false;
		}
		else {
			// 还在查找中
			lua_pushstring(L, "SEARCHING");
			return 1;
		}
	}

	// 检查结果
	if (g_spotifyResult && IsWindow(g_spotifyResult)) {
		wchar_t title[256];
		GetWindowTextW(g_spotifyResult, title, 256);

		// 转换为UTF-8
		char utf8Title[512];
		WideCharToMultiByte(CP_UTF8, 0, title, -1, utf8Title, 512, NULL, NULL);

		// 获取到结果后重置所有状态为NULL
		g_spotifyResult = NULL;
		g_spotifySearching = false;
		if (g_spotifyThread) {
			CloseHandle(g_spotifyThread);
			g_spotifyThread = NULL;
		}

		lua_pushstring(L, utf8Title);
	}
	else {
		lua_pushstring(L, "ERROR_WINDOW");
	}

	return 1;
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
