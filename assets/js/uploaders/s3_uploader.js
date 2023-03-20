export default function (entries, onViewError) {
    entries.forEach(entry => {
        // Get the presigned url from the entry.meta object.
        let { url, error } = entry.meta
        if (undefined === url) {
            throw new Error('URL was not found in entity metadata. Did get back error message: ' + error);
        }

        // Create a new XMLHttpRequest object.
        let xhr = new XMLHttpRequest()
        // Abort the request if the user navigates away from the page
        onViewError(() => xhr.abort())
        // Handle the request events.
        xhr.onload = () => ([200, 204].includes(xhr.status) ? entry.progress(100) : entry.error());
        xhr.onerror = () => entry.error()
        // Update the entity's progress value as the file uploads.
        xhr.upload.addEventListener("progress", (event) => {
            if (event.lengthComputable) {
                let percent = Math.round((event.loaded / event.total) * 100)
                if (percent < 100) { entry.progress(percent) }
            }
        })

        // Send the request.
        xhr.open("PUT", url, true)
        xhr.send(entry.file)
    })
}
