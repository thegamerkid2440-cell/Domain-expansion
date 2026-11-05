
-- GOJO DOMAIN MODULE
-- Loaded by combine.lua

return function(ctx)
    local purple = Color3.fromRGB(135, 65, 255)
    local blue = Color3.fromRGB(75, 175, 255)
    local center = ctx.center

    -- Infinite Void dome
    local dome = ctx.part(
        "InfiniteVoid",
        Vector3.new(95, 95, 95),
        CFrame.new(center),
        purple,
        0.92
    )
    dome.Shape = Enum.PartType.Ball

    -- Floating infinity energy
    for i = 1, 18 do
        local orb = ctx.part(
            "InfinityEnergy",
            Vector3.new(1.5, 1.5, 1.5),
            CFrame.new(center),
            i % 2 == 0 and blue or purple,
            0.15
        )

        orb.Shape = Enum.PartType.Ball

        ctx.effect(function(t)
            local a = t * 0.65 + i * math.pi / 9
            local r = 12 + (i % 4) * 3

            orb.Position = center + Vector3.new(
                math.cos(a) * r,
                5 + math.sin(t + i) * 7,
                math.sin(a) * r
            )
        end)
    end

    -- Infinity rotating rings
    for ring = 1, 3 do
        local disk = ctx.part(
            "InfinityRing",
            Vector3.new(22 + ring * 8, 0.2, 22 + ring * 8),
            CFrame.new(center),
            purple,
            0.76
        )

        disk.Shape = Enum.PartType.Cylinder

        ctx.effect(function(t)
            disk.CFrame =
                CFrame.new(center + Vector3.new(
                    0, ring * 4 + 2, 0
                ))
                * CFrame.Angles(
                    math.rad(90),
                    t * (ring % 2 == 0 and -1 or 1),
                    0
                )
        end)
    end

    ctx.message("GOJO: INFINITE VOID EXPANDED")
end
