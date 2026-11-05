
-- ALL DOMAINS COMBINED
-- Loaded by combine.lua

return function(ctx)
    ctx.run("GOJO")
    ctx.run("SUKUNA")
    ctx.run("BOXING")

    local center = ctx.center

    local core = ctx.part(
        "InfiniteCarnageCore",
        Vector3.new(9, 9, 9),
        CFrame.new(center + Vector3.new(0, 18, 0)),
        Color3.fromRGB(180, 55, 255),
        0.4
    )

    core.Shape = Enum.PartType.Ball

    ctx.effect(function(t)
        local size = 9 + math.sin(t * 3) * 2

        core.Size = Vector3.new(size, size, size)
        core.CFrame =
            CFrame.new(
                center + Vector3.new(
                    0, 18 + math.sin(t) * 3, 0
                )
            )
    end)

    ctx.message("INFINITE CARNAGE: ALL DOMAINS!")
end
