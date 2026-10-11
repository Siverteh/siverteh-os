.pragma library

const operations = ["tool", "route", "calculator", "legacy", "scope", "toggle", "next-wallpaper", "personality", "background", "palette-mode", "setting-toggle", "settings", "config", "form", "maintenance", "info", "url", "power", "command"];
const providers = ["apps", "wallpapers", "accents", "fonts", "software", "packages", "installed", "windows", "wifi", "bluetooth", "clipboard", "keys", "emoji", "timers", "webapps"];
const fields = ["id", "kind", "label", "description", "icon", "operation", "value", "provider", "capability", "state", "confirm", "brand", "aliases", "hidden", "arguments"];
const aliases = {favorites:"home",all:"apps",actions:"actions",settings:"setup",system:"power",clipboard:"actions.clipboard",keys:"learn.shortcuts",overview:"actions.windows",palette:"style",wallpaper:"style.wallpapers"};
const railOrder = ["home", "apps", "actions", "style", "setup", "software", "health", "learn", "power"];

function parentOf(id) { const index = id.lastIndexOf("."); return index < 0 ? "" : id.slice(0, index); }
function plain(value) { return typeof value === "string" && value.length <= 4096 && !value.includes("\0"); }
function validId(id) { return typeof id === "string" && /^[a-z][a-z0-9-]*(\.[a-z0-9-]+)*$/.test(id) && id.length <= 120; }
function validate(row, partial) {
    if (!row || typeof row !== "object" || Array.isArray(row) || !validId(row.id)) throw new Error("Menu entries need a lowercase dotted ID");
    for (const key of Object.keys(row)) {
        if (!fields.includes(key)) throw new Error("Unknown menu field: " + key);
        if (["hidden"].includes(key) && typeof row[key] !== "boolean") throw new Error("Hidden must be true or false");
        if (!["hidden", "arguments", "aliases"].includes(key) && !plain(row[key])) throw new Error("Invalid menu text: " + key);
    }
    if (!partial && (!["group", "action"].includes(row.kind) || !row.label?.trim())) throw new Error("Every menu entry needs a kind and label");
    if (row.kind !== undefined && !["group", "action"].includes(row.kind)) throw new Error("Unknown menu kind");
    if (row.operation !== undefined && !operations.includes(row.operation)) throw new Error("Unknown menu operation");
    if (row.provider !== undefined && !providers.includes(row.provider)) throw new Error("Unknown menu provider");
    for (const field of ["aliases", "arguments"]) {
        if (row[field] !== undefined && (!Array.isArray(row[field]) || row[field].length > 32 || row[field].some(value => !plain(value) || !value))) throw new Error("Invalid " + field);
    }
    if (!partial && row.kind === "action" && !operations.includes(row.operation)) throw new Error("An action needs a supported operation");
    if (row.operation === "command" && (!row.arguments?.length || row.arguments[0].startsWith("-"))) throw new Error("Commands use an explicit executable and argument array");
}
function document(text) {
    if (typeof text !== "string" || text.length > 2097152) throw new Error("Menu file is too large");
    const value = JSON.parse(text);
    if (!value || value.version !== 1 || !Array.isArray(value.entries) || value.entries.length > 1000) throw new Error("Unsupported menu format");
    return value;
}
function merge(baseText, userText) {
    const base = document(baseText), rows = base.entries.map(row => Object.assign({}, row));
    rows.forEach(row => validate(row, false));
    const ids = new Map(rows.map((row, index) => [row.id, index]));
    if (ids.size !== rows.length) throw new Error("Duplicate menu ID");
    let error = "";
    if (userText?.trim()) {
        try {
            const extension = document(userText), candidate = rows.map(row => Object.assign({}, row));
            const positions = new Map(ids), seen = new Set();
            for (const row of extension.entries) {
                validate(row, positions.has(row.id));
                if (seen.has(row.id)) throw new Error("Duplicate extension ID");
                seen.add(row.id);
                if (positions.has(row.id)) candidate[positions.get(row.id)] = Object.assign({}, candidate[positions.get(row.id)], row);
                else { positions.set(row.id, candidate.length); candidate.push(Object.assign({}, row)); }
            }
            checkTree(candidate);
            return {rows:candidate.filter(row => !row.hidden), software:base.software || [], error:""};
        } catch (failure) { error = "Menu extension: " + failure.message + ". Built-in entries remain available."; }
    }
    checkTree(rows);
    return {rows:rows.filter(row => !row.hidden), software:base.software || [], error:error};
}
function checkTree(rows) {
    const entries = new Map(rows.map(row => [row.id, row]));
    const routeAliases = new Map();
    for (const row of rows) {
        validate(row, false);
        const parent = parentOf(row.id);
        if (parent && entries.get(parent)?.kind !== "group") throw new Error("Missing group for " + row.id);
        for (const alias of row.aliases || []) {
            const key = alias.trim().toLowerCase();
            if (routeAliases.has(key) && routeAliases.get(key) !== row.id) throw new Error("Ambiguous menu alias");
            if (aliases[key] && aliases[key] !== row.id) throw new Error("Reserved route alias");
            routeAliases.set(key, row.id);
        }
    }
}
function rail(rows) {
    return rows.filter(row => !parentOf(row.id) && row.kind === "group").map((row,index) => ({row:row,index:index,order:railOrder.indexOf(row.id)}))
        .sort((a,b) => (a.order < 0 ? 99 : a.order) - (b.order < 0 ? 99 : b.order) || a.index-b.index).map(item => item.row);
}
function resolve(value, rows) {
    const route = String(value || "home").trim().toLowerCase();
    const exact = rows.find(row => row.id === route);
    if (exact) return exact.id;
    if (aliases[route] && rows.some(row => row.id === aliases[route])) return aliases[route];
    return rows.find(row => (row.aliases || []).some(alias => alias.toLowerCase() === route))?.id || "";
}
function trail(id, rows) {
    const parts = id.split("."), result = [];
    for (let index = 1; index <= parts.length; index++) {
        const row = rows.find(item => item.id === parts.slice(0,index).join("."));
        if (row) result.push({id:row.id,label:row.label});
    }
    return result;
}
function children(route, rows) { return rows.filter(row => parentOf(row.id) === route); }
function scope(query) {
    const trimmed = String(query || "").trimStart(), prefix = trimmed.charAt(0);
    const kind = ({">":"actions", "=":"calculator", "#":"brain", "?":"ai", "/":"help"})[prefix] || "all";
    return {kind:kind, text:kind === "all" ? trimmed.trim() : trimmed.slice(1).trim(), prefix:kind === "all" ? "" : prefix};
}
function normalized(value) { return String(value || "").toLowerCase().replace(/[-_:]/g," ").replace(/\s+/g," ").trim(); }
function ranked(rows, query) {
    const term = normalized(query), words = term.split(" ").filter(Boolean);
    if (!term) return rows.slice();
    const result = [];
    rows.forEach((row,index) => {
        const name = normalized(row.name || row.label), alternate = (row.aliases || []).map(normalized);
        const haystack = normalized([name,row.description,row.breadcrumb,row.id,...alternate].join(" "));
        if (!words.every(word => haystack.includes(word))) return;
        const score = name === term ? 120 : alternate.includes(term) ? 115 : name.startsWith(term) ? 100 : words.every(word => name.includes(word)) ? 85 : 55;
        result.push({row:row,index:index,score:score + (row.kind === "app" ? 3 : 0)});
    });
    return result.sort((left,right) => right.score-left.score || left.index-right.index).slice(0,100).map(hit => hit.row);
}
function firstEnabled(rows) { return rows.findIndex(row => !row.disabled); }
function step(rows,index,delta) {
    if (!rows.length) return -1;
    let next = index < 0 ? (delta < 0 ? rows.length-1 : 0) : index+delta;
    while (next >= 0 && next < rows.length) { if (!rows[next].disabled) return next; next += delta < 0 ? -1 : 1; }
    return index;
}
function stable(row) { return row.kind === "app" ? row.id : row.favoriteId || "nacre-menu:" + row.id; }
function favorite(id, apps, rows, legacy) {
    if (id.startsWith("nacre-menu:")) return rows.find(row => row.id === id.slice(11));
    if (id.startsWith("nacre-action:")) return legacy.find(row => row.id === id);
    return apps.find(row => row.id === id);
}
function alphabetical(rows) { return rows.slice().sort((a,b) => (a.name || a.label).toLowerCase().localeCompare((b.name || b.label).toLowerCase()) || stable(a).localeCompare(stable(b))); }
function application(entry) {
    const brand = ({"nacre-ai":"ai", "nacre-brain":"brain", "nacre-colors":"colors", "nacre-settings":"settings", "nacre-welcome":"welcome"})[entry.id.replace(/\.desktop$/,"")] || "";
    return {id:entry.id,kind:"app",name:entry.name,label:entry.name,description:entry.comment || "Open this application",icon:entry.icon,brand:brand,app:entry,breadcrumb:"All apps",operation:"app",disabled:false};
}
function entry(row, rows) {
    return Object.assign({}, row, {name:row.label,breadcrumb:trail(parentOf(row.id),rows).map(item => item.label).join(" › ")});
}
