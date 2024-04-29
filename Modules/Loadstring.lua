local require = {};

function require.loadsring(url)
  loadstring(game:HttpGet(url))()
end;

return require;
