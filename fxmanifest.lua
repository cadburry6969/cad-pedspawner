fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Cadburry (Bytecode Studios)'
description 'Ped spawner with interactions'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'config.lua',
    'client.lua',
}

dependencies {
    'ox_lib',
    -- 'ox_target' -- [[ This is needed if you want target interactions ]]
}