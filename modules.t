%Kevin's module library
%Some color variables begin with a capital as the keyword was taken already

var *t : int %time variable used in animation

module * framerate
    export ~.*all
    const FPS := 500
    var lastT : int := 0
    fcn timeDelay : int %ms
	var nowT : int := Time.Elapsed
	var difference : int := nowT - lastT
	lastT := nowT
	result difference
    end timeDelay
end framerate

module * kmouse
    export ~.*all
    var mouseX, mouseY, mouseB : int := 0
    var leftClicked, leftReleased, middleClicked, middleReleased, rightClicked, rightReleased : boolean := false
    proc mouseUpdate
	mousewhere (mouseX, mouseY, mouseB)
	if mouseB = 1 and leftClicked = false then
	    leftReleased := false
	    leftClicked := true
	end if
	if mouseB = 0 and leftClicked then
	    leftClicked := false
	    leftReleased := true
	else
	    leftReleased := false
	end if
	if mouseB = 10 and middleClicked = false then
	    middleReleased := false
	    middleClicked := true
	end if
	if mouseB = 0 and middleClicked then
	    middleClicked := false
	    middleReleased := true
	else
	    middleReleased := false
	end if
	if mouseB = 100 and rightClicked = false then
	    rightReleased := false
	    rightClicked := true
	end if
	if mouseB = 0 and rightClicked then
	    rightClicked := false
	    rightReleased := true
	else
	    rightReleased := false
	end if
    end mouseUpdate
    fcn mouseInRect (x1, y1, x2, y2 : real) : boolean
	result mouseX > x1 and mouseX < x2 and mouseY > y1 and mouseY < y2
    end mouseInRect
    fcn mouseInCirc (x, y, radius : real) : boolean
	result sqrt ((x - mouseX) ** 2 + (y - mouseY) ** 2) <= radius
    end mouseInCirc
end kmouse

module * vector
    export ~.*all
    type Vector :
	record
	    x, y : real
	end record
    fcn vectorNew (x, y : real) : Vector
	var v : Vector
	v.x := x
	v.y := y
	result v
    end vectorNew
    fcn vectorRandom (minX, maxX, minY, maxY : real) : Vector
	var v : Vector
	v.x := minX + (Rand.Real * (maxX - minX))
	v.y := minY + (Rand.Real * (maxY - minY))
	result v
    end vectorRandom
    fcn vectorAdd (v1, v2 : Vector) : Vector
	var v : Vector
	v.x := v1.x + v2.x
	v.y := v1.y + v2.y
	result v
    end vectorAdd
    fcn vectorSubtract (v1, v2 : Vector) : Vector
	var v : Vector
	v.x := v1.x - v2.x
	v.y := v1.y - v2.y
	result v
    end vectorSubtract
    fcn vectorMultiply (v1 : Vector, scale : real) : Vector
	var v : Vector := v1
	v.x *= scale
	v.y *= scale
	result v
    end vectorMultiply
    fcn vectorMagnitude (v1 : Vector) : real
	result sqrt (v1.x ** 2 + v1.y ** 2)
    end vectorMagnitude
    fcn vectorDot (v1, v2 : Vector) : real
	result v1.x * v2.x + v1.y * v2.y
    end vectorDot
    fcn vectorUnit (v1 : Vector) : Vector
	var v : Vector
	v.x := v1.x / vectorMagnitude (v1)
	v.y := v1.y / vectorMagnitude (v1)
	result v
    end vectorUnit
end vector

module highscore
    import File
    export setFilePath, initialize, addScore, eraseData, getName, getScore
    type Highscore :
	record
	    name : string
	    score : int
	end record
    var hs : array 1 .. 10 of Highscore
    var fileNum : int
    var fileName : string := ""
    proc setFilePath (f : string)
	fileName := f
    end setFilePath
    proc rebalance
	var done : boolean
	loop
	    done := true
	    for i : 1 .. 9
		if hs (i).score > hs (i + 1).score then
		    const storage := hs (i).score
		    hs (i).score := hs (i + 1).score
		    hs (i + 1).score := storage
		    const storage2 := hs (i).name
		    hs (i).name := hs (i + 1).name
		    hs (i + 1).name := storage2
		    done := false
		end if
	    end for
	    exit when done
	end loop
    end rebalance
    proc putInfo
	open : fileNum, fileName, put
	for i : 1 .. 10
	    put : fileNum, hs (i).score, " " ..
	    put : fileNum, hs (i).name
	end for
	close : fileNum
    end putInfo
    proc getInfo
	open : fileNum, fileName, get
	for i : 1 .. 10
	    get : fileNum, hs (i).score
	    get : fileNum, hs (i).name : *
	end for
	close : fileNum
    end getInfo
    proc addScore (name : string, score : int)
	hs (10).score := score
	hs (10).name := name
	rebalance
	putInfo
    end addScore
    proc eraseData
	for i : 1 .. 10
	    hs (i).name := "- BLANK -"
	    hs (i).score := 99999
	end for
	putInfo
    end eraseData
    proc initialize
	if File.Exists (fileName) = false then
	    eraseData
	else
	    getInfo
	end if
    end initialize
    fcn getName (n : int) : string
	result hs (n).name
    end getName
    fcn getScore (n : int) : int
	result hs (n).score
    end getScore
end highscore

module * kcolor
    export ~.*all
    type Color :
	record
	    id : int
	    r, g, b : real
	end record
    var colorId : int := 0
    fcn colorNum : int
	result colorId
    end colorNum
    fcn addColor (r, g, b : real) : Color
	var h : Color
	h.r := r
	h.g := g
	h.b := b
	result h
    end addColor
    fcn randomColor : Color
	var c : Color
	c.r := Rand.Real
	c.g := Rand.Real
	c.b := Rand.Real
	result c
    end randomColor
    fcn useColor (c : Color) : int
	var h := c
	h.id := 255
	RGB.SetColor (h.id, h.r, h.g, h.b)
	result h.id
    end useColor
    fcn saveColor (r, g, b : real) : Color
	var h : Color := addColor (r, g, b)
	h.id := colorId
	if colorId ~= 254 then
	    colorId += 1
	end if
	RGB.SetColor (h.id, h.r, h.g, h.b)
	result h
    end saveColor
    fcn mixColor (c1, c2 : Color, percentage : real) : Color
	var h : Color := addColor (c1.r * percentage + c2.r * (1 - percentage), c1.g * percentage + c2.g * (1 - percentage), c1.b * percentage + c2.b * (1 - percentage))
	h.id := 255
	RGB.SetColor (h.id, h.r, h.g, h.b)
	result h
    end mixColor
    fcn getColor (n : int) : Color
	var h : Color
	RGB.GetColor (n, h.r, h.g, h.b)
	h.id := 255
	RGB.SetColor (h.id, h.r, h.g, h.b)
	result h
    end getColor
    var Black : Color := saveColor (0, 0, 0)
    var White : Color := saveColor (1, 1, 1)
    var Red : Color := saveColor (1, 0, 0)
    var Green : Color := saveColor (0, 1, 0)
    var Blue : Color := saveColor (0, 0, 1)
    var Yellow : Color := saveColor (1, 1, 0)
    var babyBlue : Color := saveColor (0, 1, 1)
    var Magenta : Color := saveColor (1, 0, 1)
    var Purple : Color := saveColor (0.5, 0, 0.5)
    var Orange : Color := saveColor (1, 0.5, 0)
    var Grey : Color := saveColor (0.5, 0.5, 0.5)
    var lightGrey : Color := saveColor (0.75, 0.75, 0.75)
    var darkGrey : Color := saveColor (0.25, 0.25, 0.25)
    var exitRed : Color := saveColor (199 / 255, 80 / 255, 80 / 255)
    var lightExitRed : Color := saveColor (208 / 255, 108 / 255, 108 / 255)
end kcolor

module screen
    export ~.*setScreen
    proc setScreen (x, y : int, title : string)
	setscreen ("Graphics:" + intstr (x) + ";" + intstr (y) + ",title:" + title + ",position:center,center,nobuttonbar,offscreenonly")
	color (Black.id)
	colorback (White.id)
    end setScreen
end screen
