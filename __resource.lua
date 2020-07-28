resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

client_scripts {
    'config.lua',
    'client/client.lua'
}
server_scripts {
    'config.lua',
    'server.lua',
    '@mysql-async/lib/MySQL.lua'
}
ui_page('client/html/UI.html')

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

--[[ MADE BY goldblack#4418 ]]--