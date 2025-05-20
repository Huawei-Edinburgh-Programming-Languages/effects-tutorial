import stdx.effect.Command

func makePopup(msg: String) {
    println("dummy function: ${msg}")
}

class Alert <: Command<Unit> {
    Alert(let message: String = message) {}
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
    }
}

func popupHandler(fn: () -> Unit) {
    try {
        fn()
    } handle(e: Alert) {
        makePopup(e.message)
    }
}

main() {
    stdOutHandler {
        application()
    }
    
    // or
    
    popUpHandler {
        application()
    }
}