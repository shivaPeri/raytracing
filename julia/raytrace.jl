function main()

    # Image

    image_width = 256;
    image_height = 256;

    # Render

    println("P3\n", image_width, " ", image_height, "\n255");

    for j in reverse(0:(image_height-1))
        for i in 0:(image_width-1)
        
            r = Float32(i) / Float32(image_width-1)
            g = Float32(j) / Float32(image_height-1)
            b = 0.25

            ir = floor(Int, 255.999 * r)
            ig = floor(Int, 255.999 * g)
            ib = floor(Int, 255.999 * b)

            println(ir, " ", ig, " ", ib)
        end
    end

end

main()