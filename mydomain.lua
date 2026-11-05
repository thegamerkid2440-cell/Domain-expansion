
-- MY DOMAIN: CURSED ENERGY ZERO
-- Loaded by combine.lua
-- Boxing visuals; fists only as a theme

return function(ctx)
    local center = ctx.center
    local purple = Color3.fromRGB(125, 55, 255)
    local red = Color3.fromRGB(255, 45, 75)
    local black = Color3.fromRGB(17, 17, 26)

    local floor = ctx.part(
        "BoxingArena",
        Vector3.new(42, 0.5, 42),
        CFrame.new(center - Vector3.new(0, 3, 0)),
        black,
        0.05
    )
    floor.Material = Enum.Material.SmoothPlastic

    -- Ring ropes
    for _, height in ipairs({-1, 1, 3}) do
        for _, z in ipairs({-17, 17}) do
            ctx.part(
                "BoxingRope",
                Vector3.new(35, 0.3, 0.3),
                CFrame.new(
                    center + Vector3.new(0, height, z)
                ),
                purple,
                0
            )
        end

        for _, x in ipairs({-17, 17}) do
            ctx.part(
                "BoxingRope",
                Vector3.new(0.3, 0.3, 35),
                CFrame.new(
                    center + Vector3.new(x, height, 0)
                ),
                red,
                0
            )
        end
    end

    -- Corner posts
    for _, x in ipairs({-17, 17}) do
        for _, z in ipairs({-17, 17}) do
            ctx.part(
                "CornerPost",
                Vector3.new(1.1, 8, 1.1),
                CFrame.new(
                    center + Vector3.new(x, 0, z)
                ),
                purple,
                0
            )
        end
    end

    -- Arena spotlights
    for i = 1, 4 do
        local lightBall = ctx.part(
            "BoxingSpotlight",
            Vector3.new(2, 2, 2),
            CFrame.new(center),
            i % 2 == 0 and red or purple,
            0.15
        )
        lightBall.Shape = Enum.PartType.Ball

        ctx.effect(function(t)
            local angle = t * 0.5 + i * math.pi / 2
            lightBall.Position =
                center + Vector3.new(
                    math.cos(angle) * 15,
                    12,
                    math.sin(angle) * 15
                )
        end)
    end

    ctx.message(
        "CURSED ENERGY ZERO: FINAL ROUND!"
    )
end
