-- ============================================================================
-- METADATA
-- ============================================================================
script_name('MekaPL beta')
script_author('Drian')
script_description('https://github.com/adrianmafandy')

local imgui    = require 'mimgui'
local ffi      = require 'ffi'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8       = encoding.UTF8

-- ============================================================================
-- GLOBAL VARIABLES
-- ============================================================================
local showNota      = imgui.new.bool(false)
local selectedItems = {}                    
local compoRate     = imgui.new.float(3.0)  

local manualEngineCompo = imgui.new.int(0)
local manualBodyCompo   = imgui.new.int(0)
local manualTireCompo   = imgui.new.int(0)

-- ============================================================================
-- 1. CENTRAL RP CONFIG (ONGOING PROCESS)
-- ============================================================================
local manualRP = {
    engine = { 
        me = "memperbaiki komponen internal pada mesin yang bermasalah menggunakan toolkit", 
        anim = "wash", 
        do_text = "Proses perbaikan komponen mesin sedang berlangsung." 
    },
    body = { 
        me = "merapikan bagian body yang penyok menggunakan sliding hammer dan palu karet", 
        anim = "anim 1", 
        do_text = "Proses pemulihan struktur body sedang dikerjakan." 
    },
    tire = { 
        me = "mendongkrak kendaraan lalu melepas dan mengganti ban yang bermasalah", 
        anim = "bomb", 
        do_text = "Proses penggantian ban sedang dikerjakan." 
    },
    check = { 
        me = "memeriksa seluruh kondisi mesin, volume oli, serta tegangan aki kendaraan", 
        anim = "300", 
        do_text = "Proses pengecekan kondisi kendaraan sedang berjalan." 
    }
}

-- ============================================================================
-- 2. WORKSHOP DATA (ONGOING PROCESS ROLEPLAY)
-- ============================================================================
local workshopData = {
    {id = 1,  name = "Spray Car", compo = 30, me = "menyemprotkan cairan cat baru ke seluruh permukaan body menggunakan spray gun", anim = "anim 1469", do_msg = "Proses pengecatan body sedang berlangsung."},
    {id = 2,  name = "Paint Job Car", compo = 60, me = "memasang decal vinyl ke seluruh permukaan body dengan bantuan heatgun", anim = "anim 1469", do_msg = "Proses penempelan livery sedang dikerjakan."},
    {id = 3,  name = "Wheels Car", compo = 65, me = "melepas baut roda menggunakan impact wrench lalu mengganti velg dengan unit baru", anim = "bomb", do_msg = "Proses penggantian roda sedang berjalan."},
    {id = 4,  name = "Spoiler Car", compo = 60, me = "melakukan pengeboran pada bagasi lalu memasang spoiler menggunakan kunci pas", anim = "wash", do_msg = "Proses instalasi spoiler sedang dilakukan."},
    {id = 5,  name = "Hood Car", compo = 70, me = "melepas baut engsel kap mesin lama lalu menggantinya dengan kap mesin modifikasi", anim = "wash", do_msg = "Proses penggantian kap mesin sedang berlangsung."},
    {id = 6,  name = "Vents Car", compo = 70, me = "membuat lubang udara pada kap mesin lalu memasang panel vents tambahan", anim = "wash", do_msg = "Proses pemasangan lubang udara sedang berjalan."},
    {id = 7,  name = "Lights Car", compo = 70, me = "membongkar mika lampu utama lalu mengganti bohlam dengan tipe LED variasi", anim = "bomb", do_msg = "Proses pembaruan sistem lampu sedang dikerjakan."},
    {id = 8,  name = "Exhausts", compo = 80, me = "melepas klem knalpot standar lalu memasang pipa knalpot tipe racing", anim = "anim 248", do_msg = "Proses instalasi knalpot racing sedang berlangsung."},
    {id = 9,  name = "Front Bumpers", compo = 100, me = "melepas bumper depan asli lalu memasang unit bumper baru secara presisi", anim = "bomb", do_msg = "Proses pemasangan bumper depan sedang dilakukan."},
    {id = 10, name = "Rear Bumpers", compo = 100, me = "melepas bumper belakang asli lalu memasang unit bumper baru secara presisi", anim = "bomb", do_msg = "Proses pengerjaan bumper belakang sedang berjalan."},
    {id = 11, name = "Roofs Car", compo = 70, me = "memasang aksesoris tambahan pada bagian atap menggunakan perekat industri", anim = "bomb", do_msg = "Proses penempelan aksesoris atap sedang berlangsung."},
    {id = 12, name = "Side Skirts", compo = 90, me = "memasang dan mengunci panel side skirt baru pada sisi bawah kendaraan menggunakan baut tapping", anim = "bomb", do_msg = "Proses penyetelan side skirt sedang dikerjakan."},
    {id = 13, name = "Bullbars", compo = 50, me = "memasang bracket baja pada sasis depan lalu mengunci bullbar menggunakan kunci torsi", anim = "wash", do_msg = "Proses pemasangan besi pelindung sedang berjalan."},
    {id = 14, name = "Stereo", compo = 150, me = "merangkai jalur kabel kelistrikan lalu memasang unit stereo dan speaker baru di kabin", anim = "wash", do_msg = "Proses instalasi sistem audio sedang berlangsung."},
    {id = 15, name = "Hydraulics", compo = 150, me = "memasang pompa hidrolik pada suspensi lalu menghubungkan selang tekanan tinggi", anim = "anim 248", do_msg = "Proses pemasangan sistem hidrolik sedang berjalan."},
    {id = 16, name = "Nitro 1", compo = 150, me = "memasang tabung NOS (x2) ke bagasi lalu menyambungkan nozzle ke intake manifold", anim = "anim 248", do_msg = "Proses pengerjaan instalasi nitro sedang dilakukan."},
    {id = 17, name = "Nitro 2", compo = 200, me = "memasang tabung NOS (x5) serta melakukan kalibrasi pada sistem pembakaran", anim = "anim 248", do_msg = "Proses penyambungan jalur gas nitro sedang berlangsung."},
    {id = 18, name = "Nitro 3", compo = 250, me = "memasang sistem direct-port NOS (x10) dan menyetel kontroler semprotan pada ECU", anim = "anim 248", do_msg = "Proses konfigurasi sistem nitro sedang dikerjakan."},
    {id = 19, name = "Neon", compo = 300, me = "memasang bar lampu neon pada sasis bawah lalu menghubungkan kabel ke saklar interior", anim = "anim 248", do_msg = "Proses pengerjaan rangkaian neon sedang berjalan."},
    {id = 20, name = "Upgrade Body", compo = 270, me = "memasang rangka penguat (roll bar) serta plat baja tambahan pada sasis utama", anim = "anim 1", do_msg = "Proses penguatan struktur kendaraan sedang dilakukan."},
    {id = 21, name = "Upgrade Engine", compo = 280, me = "mengganti camshaft dan piston dengan tipe high-performance di dalam blok mesin", anim = "wash", do_msg = "Proses pembaruan komponen mesin sedang berlangsung."},
    {id = 22, name = "Upgrade Fuell", compo = 290, me = "melepas tangki bbm lama lalu memasang tangki kapasitas besar tipe kompetisi", anim = "wash", do_msg = "Proses pemasangan tangki bbm sedang berjalan."},
    {id = 23, name = "Plate Manipulate", compo = 50, me = "melepas plat nomor lama lalu memasang plat identitas baru pada dudukannya", anim = "bomb", do_msg = "Proses penggantian plat nomor sedang dilakukan."},
    {id = 24, name = "Remove Mods", compo = 50, me = "melepas seluruh part aftermarket lalu menginstal ulang komponen standar pabrikan", anim = "wash", do_msg = "Proses pelepasan modifikasi sedang berlangsung."},
}

-- ============================================================================
-- THEME: SEMI-TRANSPARENT & HARD COLOR LOCK (ANTI-BLUE HOVER)
-- ============================================================================
local function applyStyle()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local mainRed = imgui.ImVec4(0.55, 0.00, 0.00, 0.90)
    local hoverRed = imgui.ImVec4(0.85, 0.05, 0.05, 1.00)
    local bgAlpha = 0.70

    -- Window & Child
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.08, 0.08, 0.08, bgAlpha)
    colors[imgui.Col.ChildBg] = imgui.ImVec4(0.12, 0.12, 0.12, 0.40)
    
    -- Title
    colors[imgui.Col.TitleBg] = mainRed
    colors[imgui.Col.TitleBgActive] = hoverRed
    
    -- BUTTONS (HARD LOCK HOVER/ACTIVE)
    colors[imgui.Col.Button] = imgui.ImVec4(0.55, 0.00, 0.00, 0.85)
    colors[imgui.Col.ButtonHovered] = hoverRed
    colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.40, 0.00, 0.00, 1.00)
    
    -- HEADERS
    colors[imgui.Col.Header] = imgui.ImVec4(0.50, 0.00, 0.00, 0.60)
    colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.70, 0.00, 0.00, 0.80)
    colors[imgui.Col.HeaderActive] = mainRed
    
    -- SLIDER & FRAME (ANTI-BLUE HOVER)
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.20, 0.03, 0.03, 0.70)
    colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.35, 0.05, 0.05, 0.90)
    colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.45, 0.07, 0.07, 1.00)
    
    colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.90, 0.00, 0.00, 1.00)
    colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(1.00, 0.20, 0.20, 1.00)
    
    -- Others
    colors[imgui.Col.Border] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[imgui.Col.Separator] = imgui.ImVec4(0.55, 0.00, 0.00, 0.30)
    
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5) 
    style.FramePadding = imgui.ImVec2(6, 4)
    style.WindowRounding = 10.0
    style.FrameRounding = 5.0
    style.ChildRounding = 5.0
    style.ItemSpacing = imgui.ImVec2(8, 6)
    style.WindowPadding = imgui.ImVec2(12, 12)
    style.ChildBorderSize = 0.0
end

function calculateTotal()
    local total = 0
    for _, item in pairs(selectedItems) do
        total = total + (item.compo * compoRate[0])
    end
    return math.floor(total)
end

-- ============================================================================
-- UI RENDER LOOP
-- ============================================================================
imgui.OnFrame(function() return showNota[0] end,
function()
    applyStyle()
    local sw, sh = getScreenResolution()
    imgui.SetNextWindowSize(imgui.ImVec2(680, 880), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    
    imgui.Begin("MekaPL beta by dr14n", showNota)
    
    local winW = imgui.GetWindowWidth()
    imgui.Columns(2, "main", true)
    imgui.SetColumnWidth(0, 435) 
    
    -- --- KOLOM 1 ---
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), u8"WORKSHOP SERVICES:")
    imgui.BeginChild("LeftCol", imgui.ImVec2(0, 740), true)
    
    local rowH = 36
    local colW = imgui.GetContentRegionAvail().x

    -- MANUAL REPAIR ENGINE
    if imgui.Selectable(u8"Repair Engine##manEng", selectedItems[998] ~= nil, 0, imgui.ImVec2(200, rowH)) then
        if selectedItems[998] then selectedItems[998] = nil 
        else selectedItems[998] = {id = 998, name = "Repair Engine", compo = manualEngineCompo[0], me = manualRP.engine.me, anim = manualRP.engine.anim, isManual = true, type = "engine"} end
    end
    imgui.SameLine(215) 
    imgui.SetNextItemWidth(70)
    if imgui.InputInt(u8"##inEng", manualEngineCompo, 0, 0) then
        if selectedItems[998] then selectedItems[998].compo = manualEngineCompo[0] end
    end
    imgui.SameLine(colW - 90) 
    imgui.TextColored(imgui.ImVec4(0, 1, 0, 1), "($"..math.floor(manualEngineCompo[0] * compoRate[0])..")")

    -- MANUAL REPAIR BODY
    if imgui.Selectable(u8"Repair Body##manBody", selectedItems[999] ~= nil, 0, imgui.ImVec2(200, rowH)) then
        if selectedItems[999] then selectedItems[999] = nil 
        else selectedItems[999] = {id = 999, name = "Repair Body", compo = manualBodyCompo[0], me = manualRP.body.me, anim = manualRP.body.anim, isManual = true, type = "body"} end
    end
    imgui.SameLine(215)
    imgui.SetNextItemWidth(70)
    if imgui.InputInt(u8"##inBody", manualBodyCompo, 0, 0) then
        if selectedItems[999] then selectedItems[999].compo = manualBodyCompo[0] end
    end
    imgui.SameLine(colW - 90)
    imgui.TextColored(imgui.ImVec4(0, 1, 0, 1), "($"..math.floor(manualBodyCompo[0] * compoRate[0])..")")

    -- MANUAL REPAIR TIRE
    if imgui.Selectable(u8"Repair Tire##manTire", selectedItems[1000] ~= nil, 0, imgui.ImVec2(200, rowH)) then
        if selectedItems[1000] then selectedItems[1000] = nil 
        else selectedItems[1000] = {id = 1000, name = "Repair Tire", compo = manualTireCompo[0], me = manualRP.tire.me, anim = manualRP.tire.anim, isManual = true, type = "tire"} end
    end
    imgui.SameLine(215)
    imgui.SetNextItemWidth(70)
    if imgui.InputInt(u8"##inTire", manualTireCompo, 0, 0) then
        if selectedItems[1000] then selectedItems[1000].compo = manualTireCompo[0] end
    end
    imgui.SameLine(colW - 90)
    imgui.TextColored(imgui.ImVec4(0, 1, 0, 1), "($"..math.floor(manualTireCompo[0] * compoRate[0])..")")

    imgui.Separator()

    -- SERVICE LIST
    for _, v in ipairs(workshopData) do
        local pos = imgui.GetCursorPos()
        if imgui.Selectable(u8("##item"..v.id), selectedItems[v.id] ~= nil, 0, imgui.ImVec2(0, rowH)) then
            if selectedItems[v.id] then selectedItems[v.id] = nil else selectedItems[v.id] = v end
        end
        imgui.SetCursorPos(imgui.ImVec2(pos.x + 8, pos.y + (rowH - imgui.GetTextLineHeight())/2))
        imgui.Text(v.id .. ". " .. v.name)
        imgui.SameLine(colW - 90) 
        imgui.TextColored(imgui.ImVec4(0, 1, 0, 1), "($"..math.floor(v.compo * compoRate[0])..")")
    end
    imgui.EndChild()

    imgui.Dummy(imgui.ImVec2(0, 5))
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), u8"RATE ADJUSTMENT:")
    imgui.PushItemWidth(-1)
    imgui.SliderFloat("##rate", compoRate, 2.0, 3.0, "Rate: $%.2f")
    imgui.PopItemWidth()
    
    imgui.NextColumn()
    
    -- --- KOLOM 2 ---
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), u8"NOTA:")
    imgui.BeginChild("NotaBox", imgui.ImVec2(0, 140), true)
    for _, v in pairs(selectedItems) do
        imgui.TextWrapped(u8("- " .. v.name))
        imgui.TextColored(imgui.ImVec4(0, 1, 0, 1), "$" .. math.floor(v.compo * compoRate[0])) 
        imgui.Separator()
    end
    imgui.EndChild()
    
    imgui.Text(u8"Total: "); imgui.SameLine(); imgui.TextColored(imgui.ImVec4(0, 1, 0, 1), "$" .. calculateTotal()) 
    
    local bw = imgui.GetContentRegionAvail().x
    if imgui.Button(u8"COPY", imgui.ImVec2(bw/2-2, 38)) then
        local t = calculateTotal()
        if t > 0 then setClipboardText("$" .. t) sampAddChatMessage("{FF4444}[MekaPL]{FFFFFF} Total $"..t.." disalin!", -1) end
    end
    imgui.SameLine()
    if imgui.Button(u8"SEND", imgui.ImVec2(bw/2-2, 38)) then
        local t = calculateTotal()
        if t > 0 then sampSendChat("Total biayanya $" .. t) end
    end
    
    -- --- RESET NOTA & MANUAL INPUTS ---
    if imgui.Button(u8"RESET NOTA", imgui.ImVec2(-1, 35)) then 
        selectedItems = {} 
        manualEngineCompo[0] = 0
        manualBodyCompo[0] = 0
        manualTireCompo[0] = 0
    end
    imgui.Separator()

    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), u8"AUTO RP:")
    imgui.BeginChild("RPBox", imgui.ImVec2(0, 205), true)
    for _, v in pairs(selectedItems) do
        if imgui.Button(u8(v.name.."##"..v.id), imgui.ImVec2(-1, 38)) then
            lua_thread.create(function()
                sampSendChat("/me " .. v.me)
                sampSendChat("/" .. v.anim) 
                wait(1200) 
                local msg = v.isManual and manualRP[v.type].do_text or v.do_msg
                sampSendChat("/do " .. msg)
            end)
        end
    end
    imgui.EndChild()
    if imgui.Button(u8"DONE RP", imgui.ImVec2(-1, 38)) then sampSendChat("/do selesai") end

    -- --- QUICK ACTIONS (Updated 2-Column Grid) ---
    imgui.Dummy(imgui.ImVec2(0, 5))
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), u8"QUICK ACTIONS:")
    local qw = (imgui.GetContentRegionAvail().x / 2) - 4
    
    if imgui.Button(u8"HOOD", imgui.ImVec2(qw, 42)) then sampSendChat("/hood") end
    imgui.SameLine()
    if imgui.Button(u8"SERVICE", imgui.ImVec2(qw, 42)) then sampSendChat("/service") end
    
    if imgui.Button(u8"CHECK", imgui.ImVec2(qw, 42)) then
        lua_thread.create(function()
            sampSendChat("/me " .. manualRP.check.me)
            sampSendChat("/anim " .. manualRP.check.anim)
            wait(1500); sampSendChat("/do " .. manualRP.check.do_text)
        end)
    end
    imgui.SameLine()
    if imgui.Button(u8"INV", imgui.ImVec2(qw, 42)) then sampSendChat("/inv") end
    
    if imgui.Button(u8"WSMENU", imgui.ImVec2(qw, 42)) then sampSendChat("/wsmenu") end
    imgui.SameLine()
    if imgui.Button(u8"TRUNK", imgui.ImVec2(qw, 42)) then sampSendChat("/trunk") end

    if imgui.Button(u8"DUTY", imgui.ImVec2(-1, 42)) then sampSendChat("/mechduty") end
    
    imgui.End()
end)

function main()
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage("{FF4444}[MekaPL]:{FFFFFF} Loaded! Use {FF4444}/mkpl{FFFFFF}.", -1)
    sampRegisterChatCommand("mkpl", function() showNota[0] = not showNota[0] end)
    wait(-1)
end
