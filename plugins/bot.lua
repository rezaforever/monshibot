local function parsed_url(link)
  local parsed_link = URL.parse(link)
  local parsed_path = URL.parse_path(parsed_link.path)
  return parsed_path[2]
end

function reload_plugins( )
  plugins = {}
  load_plugins()
end

local function sudolist(msg)
local sudo_users = _config.sudo_users
local text = "لیست افراد مدیر :\n"
for i=1,#sudo_users do
    text = text..i.." - "..sudo_users[i].."\n"
end
return text
end

local function run(msg, matches)
--------------------------------------------------
if msg.text and is_sudo(msg) and not redis:get(main) then
return false
end
--------------------------------------------------
--TAG
local tag = matches[2]
local hash = "tag:"..msg.from.id
local sendpm = 92635028
if matches[1] == "تنظیم تگ" and is_sudo(msg) then
redis:set(hash, tag)
return "تگ جدید با موفقیت ثبت شد"
end
if matches[1] == "تگ" and is_sudo(msg) then
if redis:get(hash) then
return "تگ فعلی : "..tag
else
return "شما هنوز هیچ تگی تنظیم نکرده اید !"
end
end
if matches[1] == "حذف تگ" and is_sudo(msg) then
if redis:get(hash) then
redis:del(hash)
return "تگ با موفقیت حذف شد !"
else
return "شما هنوز هیچ تگی تنظیم نکرده اید !"
end
end
--REALM
if matches[1] == "تنظیم گروه" and is_sudo(msg) then
local realm = msg.to.id
local main = "realm"
redis:set(main, msg.to.id)
return "گروه مدیریتی جدید با موفقبت شد !"
end
--SET JOIN
if matches[1] == "جوین" and is_sudo(msg) then
if matches[2] == "روشن" then
if not redis:get("joinchat") then
redis:set("joincht", true)
return "جوین اتوماتیک داخل گروه ها روشن شد !"
else
return "جوین اتوماتیک داخل گروه ها از قبل روشن بوده است !"
end
end
if matches[2] == "خاموش" then
if redis:get("joinchat") then
redis:del("joinchat")
return "جویوماتیک داخل گروه ها خاموش شد !"
else
return "جوین اتوماتیک داخل گروه ها از قبل خاموش بوده است !"
end
end
end
if matches[1] == "وضعیت جوین" and is_sudo(msg) then
if redis:get("joinchat") then
return "جوین اتوماتیک روشن است !"
else
return "جوین اتوماتیک خاموش است !"
end
end
--JOIN AND SEND
if msg.text:match("https://t.me/joinchat/%S+") or msg.text:match("https://telegram.me/joinchat/%S+") or text:match("https://telegram.dog/joinchat/%S+") then
if redis:get("joinchat") then
if redis:get(main) then
local joinchat = parsed_url(matches[1])   
join = import_chat_link(joinchat,ok_cb,false)
if is_sudo(msg) then
return "جوین شدم !"
else
return true
end
local realm = redis:get(main)
local pm = msg.text
send_large_msg("chat#id"..realm or "channel#id"..realm, pm)
else
local txt = "ربات لینک دریافت کرده است ولی بدلیل نبودن گروه مدیریتی لینک فرستاده نشد!/nبرای دریافت لینک های دریافتی ربات را در یک گروه اضافه کرده و دستور .تنظیم گروه را ارسال کنید !"
send_large_msg("user#id"..sendpm, txt)
end
end
end
--SUDO
if matches[1] == "لیست مدیر" and is_sudo(msg) then
return sudolist(msg)
end
if tonumber (msg.from.id) == 92635028 then--expample 123456789
if matches[1]:lower() == "تنظیم مدیر" then
table.insert(_config.sudo_users, tonumber(matches[2]))
print(matches[2]..' added to sudo users')
save_config()
reload_plugins(true)
return 'کاربر'..matches[2]..'با موفقیت مدیر شد'
elseif matches[1]:lower() == "حذف مدیر" then
table.remove(_config.sudo_users, tonumber(matches[2]))
print(matches[2]..' removed from sudo users')
save_config()
reload_plugins(true)
return 'کاربر'..matches[2]..'با موفقیت از مدیریت ربات حذف شد'
end
end
end
--END 50%
return {
  patterns = {
	"^[.](وضعیت جوین)$",
	"^[.](جوین) (.*)$",
	"^[.](تنظیم گروه)$",
	"^[.](حذف تگ)$",
	"^[.](تگ)$",
	"^[.](تنظیم تگ) (.*)$",
	"^[.](تنظیم مدیر)$",
	"^[.](تنظیم مدیر) (%d+)$",
	"^[.](حذف مدیر) (%d+)$",
	"(https://telegram.me/joinchat/%S+)",
	"(https://t.me/joinchat/%S+)",
	"(https://telegram.dog/joinchat/%S+)",
  }, 
  run = run
}