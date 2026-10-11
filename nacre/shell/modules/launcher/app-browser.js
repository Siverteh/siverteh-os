.pragma library
const groups = [
    { id: "favorites", label: "Favorites", icon: "favorite" },
    { id: "actions", label: "Actions", icon: "bolt" },
    { id: "all", label: "All apps", icon: "apps" },
    { id: "development", label: "Development", icon: "code", categories: ["Development"] },
    { id: "media", label: "Media", icon: "movie", categories: ["AudioVideo", "Audio", "Video"] },
    { id: "games", label: "Games", icon: "sports_esports", categories: ["Game"] },
    { id: "graphics", label: "Graphics", icon: "palette", categories: ["Graphics"] },
    { id: "internet", label: "Internet", icon: "public", categories: ["Network"] },
    { id: "office", label: "Office", icon: "description", categories: ["Office"] },
    { id: "education", label: "Education", icon: "school", categories: ["Education", "Science"] },
    { id: "system", label: "System", icon: "settings", categories: ["System", "Settings"] },
    { id: "utilities", label: "Utilities", icon: "build", categories: ["Utility"] }
];
function belongs(app, group) {
    const rule = groups.find(item => item.id === group);
    return !!rule && (rule.categories || []).some(category => (app.categories || []).includes(category));
}
function available(apps) {
    return groups.filter(group => !group.categories || apps.some(app => belongs(app, group.id)));
}
function matches(item, query) {
    return (item.name + " " + (item.description || "")).toLowerCase().includes(query.toLowerCase());
}

function actions(items) {
    return items.filter(item => item.action !== "power").map(item => Object.assign({}, item, {
        id: "nacre-action:" + item.action + ":" + encodeURIComponent(item.value || ""),
        kind: "action"
    }));
}
function favorite(id, apps, actions) {
    return id.startsWith("nacre-action:") ? actions.find(item => item.id === id) : apps.find(item => item.id === id);
}
