import stdx.effect.Command

func makePopup(msg: String) {
    println("dummy function: ${msg}")
}

class Alert <: Command<Unit> {
    Alert(let message: String) {}
}

func app() {
    var error = true
    if (error) {
        perform Alert("error")
    }
}

func stdOutHandler(fn: () -> Unit) {
    try {
        fn()
    } handle(e: Alert) {
        println(e.message)
        resume
    }
}

func popUpHandler(fn: () -> Unit) {
    try {
        fn()
    } handle(e: Alert) {
        makePopup(e.message)
        resume
    }
}

main() {
    stdOutHandler {
        app()
    }
    
    // or
    
    popUpHandler {
        app()
    }
}