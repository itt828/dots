import { App } from "astal/gtk3"
import style from "./style.scss"
import Bar from "./widget/Bar"
import { Notifications } from "./widget/Notifications"

App.start({
    css: style,
    main() {
        App.get_monitors().map(Bar)
        // Notifications(App.get_monitors()[0])
    },
})
