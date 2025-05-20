import stdx.effect.Command

class Alert <: Command<Unit> {
    Alert(let message: String = message) {}
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

func app() {
    var error = true
    if (error) {
        perform Alert("error")
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