export default function (entries, onViewError) {

    // Right now, this is built with the assumptions that Chris bulit which attaches the upload constraints via `fields` to the xhr network request so they are honored by S3. For now, we may want to skip this and just upload everything.

    entries.forEach(entry => {
        let formData = new FormData()
        let { url, fields } = entry.meta
        Object.entries(fields).forEach(([key, val]) => formData.append(key, val))
        formData.append("file", entry.file)
        let xhr = new XMLHttpRequest()
        onViewError(() => xhr.abort())
        xhr.onload = () => xhr.status === 204 ? entry.progress(100) : entry.error()
        xhr.onerror = () => entry.error()
        xhr.upload.addEventListener("progress", (event) => {
            if (event.lengthComputable) {
                let percent = Math.round((event.loaded / event.total) * 100)
                if (percent < 100) { entry.progress(percent) }
            }
        })

        xhr.open("POST", url, true)
        xhr.send(formData)
    })
}
