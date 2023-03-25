// TODO: document this hook

export default {
    mounted() {
        console.log("mounted");

        // Assumption: There is only one file input in this form.
        fileInput = this.el.querySelector('input[type="file"]');
        // Assumption: This form has a textarea with id "new_article_body".
        bodyTextarea = this.el.querySelector('input#new_article_body');

        // As the user selects a file, update the textarea
        fileInput.addEventListener('change', function () {
            console.log("change event");
            console.log(fileInput.files);
            // For each file of the file input, add a link to the textarea.
            for (let i = 0; i < fileInput.files.length; i++) {
                // Get the filename of the current file.
                const filename = fileInput.files[i].name;
                console.log("filename = " + filename);

                // Get the current cursor position in the textarea.
                const cursorPos = bodyTextarea.selectionStart;

                // Split the bodyTextarea content into two parts
                const start = bodyTextarea.value.substring(0, cursorPos);
                const end = bodyTextarea.value.substring(cursorPos);

                // Update the bodyTextarea element with the desired text
                const uploadMessage = `<!-- Uploading ${filename}... -->`
                bodyTextarea.value = start + uploadMessage + end;

                // Set the cursor position to the end of the inserted text
                bodyTextarea.selectionStart = cursorPos + uploadMessage.length;
                bodyTextarea.selectionEnd = bodyTextarea.selectionStart;
            }
            // // Get the current cursor position in the textarea
            // const cursorPos = textarea.selectionStart;

            // // Split the textarea content into two parts
            // const start = textarea.value.substring(0, cursorPos);
            // const end = textarea.value.substring(cursorPos);

            // // Update the textarea element with the desired text
            // textarea.value = start + `<!-- Uploading ${filename}... -->` + end;

            // // Set the cursor position to the end of the inserted text
            // textarea.selectionStart = cursorPos + (`<!-- Uploading ${filename}... -->`).length;
            // textarea.selectionEnd = textarea.selectionStart;
        });
    },
    destroyed() {
        //this.el.removeEventListener('change', this.beforeUnloadHandler, true)
    },
}
