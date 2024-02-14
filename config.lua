PedTypes = {
    male = 4,
    female = 5
}

PedList = {
    --[[ Below is a demo to add peds with interactions ]]
    ['test_ped'] = {
        model = 'ig_barry',
        coords = vector4(110.27, -1088.27, 29.3, 337.37),
        type = 'male',
        distance = 5.0,
        states = {
            freeze = true,
            blockevents = true,
            invincible = true,
        },
        animation = { -- [[ comment dict/anim/duration/flag & uncomment scenario if you want to use scenario ]]
            dict = 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a',
            anim = 'idle_a',
            duration = -1, -- milliseconds [[ remove this or set it to `-1` if you dont want to stop then animation ]]
            flag = 63,
            -- scenario = 'WORLD_HUMAN_SMOKING'
        },
        prop = {
            model = 'prop_cs_tablet',
            bone = 28422,
            rotation = vec3(0.0, 0.0, 0.03),
            offset = vec3(0.0, 0.0, 0.03),
        },
        interaction = {
            label = '[E] Interact',
            distance = 2.0,
            key = 38, -- E: 38 ( refer: https://docs.fivem.net/docs/game-references/controls/ )
            onPressed = function(self)
                print('onPressed', self.id)
            end
        },
        target = { -- [[ You can add as many options for the target, refer: https://overextended.dev/ox_target/Options ]]
            {
                label = 'Test',
                icon = 'fa-solid fa-question',
                onSelect = function(self)
                    print('onTarget', self.entity)
                end
            }
        },
        onSpawn = function(self)
            print('onSpawn', self.ped)
        end,
        onDespawn = function(self)
            print('onDespawn', self.ped)
        end
    },
}
