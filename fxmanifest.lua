fx_version 'cerulean'
game 'gta5'

author 'Nyxon#4418'
description 'Extended banking script'
version '3.0'


client_scripts {
    'config.lua',
    'client/client.lua'
}

server_scripts {
    'config.lua',
    'server/server.lua',
    '@mysql-async/lib/MySQL.lua'
}

ui_page 'client/html/UI.html'

files {
	'client/html/UI.html',
    'client/html/style.css',
    'client/html/index.js',
    'client/html/media/font/Bariol_Regular.otf',
    'client/html/media/font/Vision-Black.otf',
    'client/html/media/font/Vision-Bold.otf',
    'client/html/media/font/Vision-Heavy.otf',
    'client/html/media/img/bg.png',
    'client/html/media/img/circle.png',
    'client/html/media/img/curve.png',
    'client/html/media/img/fingerprint.png',
    'client/html/media/img/fingerprint.jpg',
    'client/html/media/img/graph.png',
    'client/html/media/img/logo-big.png',
    'client/html/media/img/logo-top.png'
}

--[[ MADE BY Nyxon#4418 ]]--