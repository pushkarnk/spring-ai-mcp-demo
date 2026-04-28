@param String extAppsJs

<!DOCTYPE html>
<html>
<head>
    <title>Ubuntu Mascot</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0; padding: 24px; text-align: center;
            background: #f8f9fa; color: #1a1a2e;
        }
        @media (prefers-color-scheme: dark) {
            body { background: #1d1e22; color: #e8e8e8; }
            select { background: #16213e; color: #e8e8e8; border-color: #533483; }
        }
        h1 { font-size: 22px; margin: 0 0 16px; }
        .controls { margin-bottom: 16px; }
        select {
            font-size: 15px; padding: 8px 12px; border-radius: 8px;
            border: 2px solid #e0e0e0; outline: none;
        }
        .name { font-size: 18px; font-weight: 600; margin: 12px 0; }
        .mascot {
            display: flex; justify-content: center; align-items: center;
            min-height: 240px;
        }
        .mascot svg { max-width: 320px; max-height: 320px; }
        .empty { color: #888; font-style: italic; }
    </style>
</head>
<body>

<h1>Ubuntu Mascot</h1>

<div class="controls">
    <label for="version">Version: </label>
    <select id="version"></select>
</div>

<div class="name" id="name">—</div>
<div class="mascot" id="mascot"><span class="empty">Loading…</span></div>

<script id="ext-apps-src" type="text/plain">
$unsafe{extAppsJs}
</script>

<script type="module">
    const src = document.getElementById('ext-apps-src').textContent;
    const blob = new Blob([src], { type: 'application/javascript' });
    const url = URL.createObjectURL(blob);
    const { App } = await import(url);
    URL.revokeObjectURL(url);

    const app = new App({ name: "show-ubuntu-mascot", version: "1.0.0" });
    await app.connect();

    const versions = [
        "4.10","5.04","5.10","6.06","6.10","7.04","7.10","8.04","8.10",
        "9.04","9.10","10.04","10.10","11.04","11.10","12.04","12.10",
        "13.04","13.10","14.04","14.10","15.04","15.10","16.04","16.10",
        "17.04","17.10","18.04","18.10","19.04","19.10","20.04","20.10",
        "21.04","21.10","22.04","22.10","23.04","23.10","24.04","24.10",
        "25.04","25.10","26.04"
    ];

    const select = document.getElementById('version');
    versions.forEach(v => {
        const opt = document.createElement('option');
        opt.value = v;
        opt.textContent = v;
        select.appendChild(opt);
    });
    select.value = "24.04";

    const nameEl = document.getElementById('name');
    const mascotEl = document.getElementById('mascot');

    async function load(version) {
        const result = await app.callServerTool({
            name: "show-ubuntu-mascot",
            arguments: { version },
        });
        const data = result.structuredContent ?? {};
        nameEl.textContent = "Ubuntu " + (data.version || version) + " — " + (data.name || "Unknown");
        if (data.svg) {
            mascotEl.innerHTML = data.svg;
        } else {
            mascotEl.innerHTML = '<span class="empty">No mascot SVG available</span>';
        }
        await app.sendMessage({
            role: "user",
            content: [{ type: "text", text: "Showing Ubuntu " + (data.version || version) + " — " + (data.name || "Unknown") }],
        });
    }

    select.addEventListener('change', () => load(select.value));
    load(select.value).then(() => {});
</script>

</body>
</html>
