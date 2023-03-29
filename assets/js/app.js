import Uploaders from './uploaders';
import AdminHooks from './admin/hooks';

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

liveSocketConfig = {
    uploaders: Uploaders,
    params: { _csrf_token: csrfToken }
}

// FIXME: These hooks are only needed for the admin pages, so we look for
// Primer's Session and Prompt objects before assigning the hooks. In the
// future, we should consider making an admin-only specific app.js file to avoid
// this clunky logic.
// https://github.com/zorn/franklin/issues/226
if (typeof Prompt !== 'undefined' && typeof Session !== 'undefined') {
    liveSocketConfig.hooks = {
        Prompt,
        Session,
        ...AdminHooks
    }
}

let liveSocket = new LiveSocket("/live", Socket, liveSocketConfig)

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
