fx_version 'cerulean'
games { 'gta5' }

client_scripts {
    --'ScaleformUI.lua',
	'client/objs.lua',
	'client/raycast.lua',
	'client/main.lua',
    '@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/script.js',
    'html/style.css'
}

server_scripts {
	--'server/main.lua',
}

lua54 'yes'