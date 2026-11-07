Utils.progressBar = (() => {
    const DEFAULT_DURATION = 3000;
    const HIDE_DELAY = 1000; // how long the "completed" state stays on screen

    const wrapper = document.getElementById("progress-bar-wrapper");
    const fill = wrapper.querySelector(".progress-bar");
    const percentNum = wrapper.querySelector(".pb-num");
    const stateText = wrapper.querySelector(".status .state");
    const timeText = wrapper.querySelector(".pb-time");

    let animationFrame = null;
    let hideTimeout = null;
    let progress = 0;
    let completed = false;
    let lastPercent = -1;
    let lastTenths = -1;

    function isValidColor(color) {
        return typeof color === "string" && color !== "" && (!window.CSS || CSS.supports("color", color));
    }

    function render(percent) {
        fill.style.width = percent + "%";

        // only touch the DOM text when the visible value actually changes
        const shown = Math.floor(percent);
        if (shown !== lastPercent) {
            lastPercent = shown;
            percentNum.textContent = shown;
        }
    }

    function setRemaining(ms) {
        const tenths = Math.ceil(Math.max(ms, 0) / 100);
        if (tenths !== lastTenths) {
            lastTenths = tenths;
            timeText.textContent = (tenths / 10).toFixed(1) + "s";
        }
    }

    function hide() {
        // recheck: update() may have moved the bar below 100% again during the delay
        if (completed) wrapper.classList.remove("active");
    }

    function update(percent, progress_bar_id) {
        progress = Math.min(Math.max(Number(percent) || 0, 0), 100);
        render(progress);

        if (progress >= 100) {
            if (completed) return; // never fire the completion twice
            completed = true;
            wrapper.classList.add("done");
            setRemaining(0);
            Utils.post("progressBarComplete", { progress_bar_id: progress_bar_id }, "progressBarComplete");

            clearTimeout(hideTimeout);
            hideTimeout = setTimeout(hide, HIDE_DELAY);
        } else if (completed) {
            completed = false;
            wrapper.classList.remove("done");
        }
    }

    function startProgress(progress_bar_id, duration = DEFAULT_DURATION, label = "", color = null) {
        cancelAnimationFrame(animationFrame);
        clearTimeout(hideTimeout); // a pending hide from a previous bar must not close this one

        duration = Number(duration) > 0 ? Number(duration) : DEFAULT_DURATION;

        // reset visuals *before* showing, so the previous bar's 100% never flashes
        completed = false;
        lastPercent = -1;
        lastTenths = -1;
        wrapper.classList.remove("done");
        render(0);
        setRemaining(duration);

        stateText.textContent = label || "";
        // no/invalid color -> fall back to the theme primary (--lc-primary in theme.css)
        if (isValidColor(color)) {
            wrapper.style.setProperty("--pb-accent", color);
        } else {
            wrapper.style.removeProperty("--pb-accent");
        }
        wrapper.classList.add("active");

        let start = null;
        const step = (timestamp) => {
            if (start === null) start = timestamp;
            const elapsed = timestamp - start;
            const percent = Math.min(elapsed / duration, 1) * 100;

            update(percent, progress_bar_id);

            if (percent < 100) {
                setRemaining(duration - elapsed);
                animationFrame = requestAnimationFrame(step);
            }
        };

        animationFrame = requestAnimationFrame(step);
    }

    function reset() {
        cancelAnimationFrame(animationFrame);
        clearTimeout(hideTimeout);
        update(0);
    }

    return { startProgress, update, reset };
})();
