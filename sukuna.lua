
-- SUKUNA DOMAIN MODULE
-- Loaded by combine.lua

return function(ctx)
    local red = Color3.fromRGB(255, 38, 65)
    local dark = Color3.fromRGB(35, 5, 12)
    local center = ctx.center

    local altar = ctx.part(
        "MalevolentShrine",
        Vector3.new(16, 12, 12),
        CFrame.new(center + Vector3.new(0, 3, -22)),
        dark,
        0.12
    )
    altar.Material = Enum.Material.Slate

    -- Shrine spikes
    for i = -3, 3 do
        local spike = ctx.part(
            "ShrineSpike",
            Vector3.new(2, 12 + math.abs(i) * 2, 2),
            CFrame.new(
                center + Vector3.new(i * 5, 5, -27)
            ),
            red,
            0.1
        )

        spike.Material = Enum.Material.Neon
    end

    -- Malevolent slash effects
    for i = 1, 20 do
        local slash = ctx.part(
            "DismantleSlash",
            Vector3.new(0.15, 10, 0.55),
            CFrame.new(center),
            red,
            0.12
        )

        ctx.effect(function(t)
            local angle = t * 2.2 + i * 1.9
            local distance = 4 + i * 1.1

            slash.CFrame =
                CFrame.new(
                    center + Vector3.new(
                        math.cos(angle) * distance,
                        3 + math.sin(t * 2 + i) * 5,
                        math.sin(angle) * distance
                    )
                )
                * CFrame.Angles(
                    angle,
                    angle * 0.5,
                    math.rad(40)
                )
        end)
    end

    -- Crimson domain floor
    ctx.part(
        "MalevolentFloor",
        Vector3.new(65, 0.35, 65),
        CFrame.new(center - Vector3.new(0, 3, 0)),
        red,
        0.79
    )

    ctx.message("SUKUNA: MALEVOLENT SHRINE EXPANDED")
end
