Utils.progressBar = (() => {
    let animationFrame = null;
    let progress = 0;

    const wrapper = document.getElementById("progress-bar-wrapper");
    const progressBar = wrapper.querySelector(".progress-bar");
    const percentageText = wrapper.querySelector(".percentage");
    const stateText = wrapper.querySelector(".status .state");

    function update(percent, progress_bar_id) {
        progress = Math.min(Math.max(percent, 0), 100);
        progressBar.style.width = progress + "%";
        percentageText.setAttribute("data-progress", Math.floor(progress));
        percentageText.style.setProperty("--percent", `'${Math.floor(progress)}%'`);
        percentageText.innerText = `${Math.floor(progress)}%`;

        if (progress >= 100) {
            // wait 1 s before closing it
            Utils.post("progressBarComplete", { progress_bar_id: progress_bar_id }, "progressBarComplete");
            setTimeout(() => {
                // recheck if it is still 100
                if (progress >= 100) {
                    wrapper.classList.remove("active");
                }
            }, 1000);
        }
    }

    function startProgress(progress_bar_id, duration = 3000, label = "", color = "#375a7f") {
        let start = null;
        wrapper.classList.add("active");
        stateText.innerText = label;
        progressBar.style.background = color;

        const step = (timestamp) => {
            if (!start) start = timestamp;
            const delta = timestamp - start;
            const percent = Math.min(delta / duration, 1) * 100;

            update(percent, progress_bar_id);

            if (percent < 100) {
                animationFrame = requestAnimationFrame(step);
            }
        };

        cancelAnimationFrame(animationFrame);
        animationFrame = requestAnimationFrame(step);
    }

    function reset() {
        cancelAnimationFrame(animationFrame);
        update(0);
    }

    return { startProgress, update, reset };
})();