// TextareaMutation
//
// A hook that can be attached to a textarea element so that from the LiveView
// we can mutate the text of said textarea element.
//
// Note: `textarea_inject_request` is built with some assumptions about our
// admin article editor use case in mind. It could be generalized in the
// future, but right now we are going to accept with this coupling.

export default {
    mounted() {

        // This event is triggered from the LiveView when we want to inject
        // some text into the textarea and honor the current cursor position.
        this.handleEvent('textarea_inject_request', ({ content }) => {
            // Get the current cursor position in the textarea.
            const cursorPos = this.el.selectionStart;

            // Split the this content into two parts
            const start = this.el.value.substring(0, cursorPos);
            const end = this.el.value.substring(cursorPos);

            // If the start string ends with `-->` then we will insert a new
            // line because we we never want upload comments (for what this more
            // generic hook is used for) to be on the same line.
            if (start.endsWith("-->")) {
                content = "\n" + content;
            }

            // Update the this element with the desired text
            this.el.value = start + content + end;

            // Set the cursor position to the end of the inserted text
            this.el.selectionStart = cursorPos + content.length;
            this.el.selectionEnd = this.el.selectionStart;

            this.pushEvent("update_body", { "body": this.el.value })
        });
        // This event is triggered from the LiveView when we want to replace
        // some text in the textarea.
        this.handleEvent('textarea_replace_request', ({ target, replacement }) => {
            this.el.value = this.el.value.replace(new RegExp(target, "g"), replacement);
        });
    },
}
