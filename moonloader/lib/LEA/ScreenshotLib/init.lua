---@diagnostic disable: undefined-global

local ffi = require("ffi")
ffi.cdef [[
  struct RECT {
    long left;
    long top;
    long right;
    long bottom;
  };

  void* ScreenshotLibInitialize(unsigned int device, struct RECT rect);
  void ScreenshotLibShutdown(void* core);
  void ScreenshotLibInvalidate(void* core);
  int ScreenshotLibSaveToFile(void* core, const char* path);
  int ScreenshotLibSaveToFileAsync(void* core, const char* path);
  void ScreenshotLibProcessEvents(void* core);
  int ScreenshotLibIsBusy(void* core);
  int ScreenshotLibHasResult(void* core);
  int ScreenshotLibLastOperationSucceeded(void* core);
  const unsigned char* ScreenshotLibGetResultData(void* core);
  unsigned int ScreenshotLibGetResultSize(void* core);
  void ScreenshotLibClearResult(void* core);
]]

local function getModuleDirectory()
  local source = debug.getinfo(1, "S").source
  if source:sub(1, 1) == "@" then
    source = source:sub(2)
  end
  return source:match("^(.*)[/\\][^/\\]+$")
end

local moduleDir = getModuleDirectory()
local lib = ffi.load(moduleDir .. [[\ScreenshotLib]])

local ScreenshotLib = {}
ScreenshotLib.__index = ScreenshotLib

function ScreenshotLib:new(minX, minY, maxX, maxY)
  local instance = setmetatable({}, ScreenshotLib)
  instance._pendingCallback = nil

  if minX == nil or minY == nil or maxX == nil or maxY == nil then
    minX, minY = 0, 0
    maxX, maxY = getScreenResolution()
  end

  local rect = ffi.new("struct RECT")
  rect.left = minX
  rect.top = minY
  rect.right = maxX
  rect.bottom = maxY
  instance.core = lib.ScreenshotLibInitialize(getD3DDevicePtr(), rect)

  addEventHandler("onD3DDeviceLost", function()
    if instance.core ~= nil then
      lib.ScreenshotLibInvalidate(instance.core)
    end
  end)

  addEventHandler("onScriptTerminate", function(scr)
    if scr == thisScript() then
      local core = instance.core
      instance.core = nil
      instance._pendingCallback = nil

      if core ~= nil then
        pcall(function()
          lib.ScreenshotLibProcessEvents(core)
        end)
        lib.ScreenshotLibShutdown(core)
      end
    end
  end)

  return instance
end

function ScreenshotLib:processEvents()
  if self.core == nil then
    return
  end

  lib.ScreenshotLibProcessEvents(self.core)

  if lib.ScreenshotLibHasResult(self.core) == 0 then
    return
  end

  local success = lib.ScreenshotLibLastOperationSucceeded(self.core) ~= 0
  local size = tonumber(lib.ScreenshotLibGetResultSize(self.core)) or 0
  local data = lib.ScreenshotLibGetResultData(self.core)
  local bytes = nil

  if success and data ~= nil and size > 0 then
    bytes = ffi.string(data, size)
  end

  local callback = self._pendingCallback
  self._pendingCallback = nil
  lib.ScreenshotLibClearResult(self.core)

  if callback ~= nil then
    local ok, err = pcall(callback, success, bytes, size)
    if not ok then
      print("[ScreenshotLib] callback error: " .. tostring(err))
    end
  end
end

function ScreenshotLib:dispatchCallbacks()
  self:processEvents()
end

function ScreenshotLib:save(path)
  if self.core == nil then
    return false
  end
  return lib.ScreenshotLibSaveToFile(self.core, path) ~= 0
end

function ScreenshotLib:saveAsync(path, callback)
  if self.core == nil then
    return false
  end

  if self:isBusy() or lib.ScreenshotLibHasResult(self.core) ~= 0 then
    return false
  end

  local success = lib.ScreenshotLibSaveToFileAsync(self.core, path) ~= 0
  if success then
    self._pendingCallback = callback
  end

  return success
end

function ScreenshotLib:isBusy()
  if self.core == nil then
    return false
  end
  return lib.ScreenshotLibIsBusy(self.core) ~= 0
end

return ScreenshotLib